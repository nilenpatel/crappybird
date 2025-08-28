import tkinter as tk
from tkinter import ttk
import threading
import time
from datetime import datetime, timedelta
from collections import deque
import json
import os
import platform
import socket

import psutil
import requests

from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np


class CyberTechSystemMonitor:
    """
    Advanced System & API Monitoring Dashboard
    Features real-time hardware monitoring, API status tracking, and performance analytics
    """
    
    def __init__(self, root_window, api_base_url="http://127.0.0.1:5000"):
        # Core Configuration
        self.root_window = root_window
        self.api_base_url = api_base_url
        self.monitoring_active = True
        self.update_interval_ms = 1000  # 1 second
        self.api_check_interval_ms = 5000  # 5 seconds
        self.graph_data_points_max = 60  # 1 minute of data
        
        # Initialize UI
        self._initialize_window_properties()
        self._configure_visual_styles()
        
        # System Metrics Storage
        self.system_metrics = {
            'cpu_usage_percentage': deque(maxlen=self.graph_data_points_max),
            'memory_usage_percentage': deque(maxlen=self.graph_data_points_max),
            'disk_usage_percentage': deque(maxlen=self.graph_data_points_max),
            'network_speed_mbps': deque(maxlen=self.graph_data_points_max),
            'gpu_usage_percentage': deque(maxlen=self.graph_data_points_max),
            'system_temperature_celsius': deque(maxlen=self.graph_data_points_max)
        }
        
        # Network Monitoring State
        self.network_monitoring_state = {
            'previous_bytes_total': None,
            'previous_timestamp': None,
            'current_download_speed_mbps': 0.0,
            'current_upload_speed_mbps': 0.0
        }
        
        # API Monitoring State
        self.api_monitoring_state = {
            'connection_status': "🔍 INITIALIZING",
            'response_time_ms': 0,
            'last_check_timestamp': "System Starting",
            'status_color': "#ffaa00",
            'available_endpoints': [],
            'error_count': 0,
            'success_count': 0
        }
        
        # System Information Cache
        self.system_info_cache = self._gather_system_information()
        
        # Performance Alerts
        self.performance_alerts = {
            'cpu_high_usage_threshold': 85.0,
            'memory_high_usage_threshold': 90.0,
            'disk_high_usage_threshold': 95.0,
            'temperature_high_threshold': 80.0,
            'active_alerts': set()
        }
        
        # Build Dashboard
        self._construct_main_dashboard()
        self._initialize_monitoring_systems()

    def _initialize_window_properties(self):
        """Configure main window properties and behavior"""
        self.root_window.title("🚀 CYBER TECH SYSTEM MONITOR - Advanced Dashboard v2.0")
        self.root_window.geometry("1800x1200")
        self.root_window.minsize(1400, 900)
        self.root_window.configure(bg="#0a0a0f")
        
        # Configure grid weights for responsive design
        self.root_window.grid_rowconfigure(0, weight=1)
        self.root_window.grid_columnconfigure(0, weight=1)
        
        # Window icon and additional properties
        try:
            self.root_window.iconname("CyberTech Monitor")
            self.root_window.wm_attributes("-alpha", 0.98)  # Slight transparency
        except:
            pass

    def _configure_visual_styles(self):
        """Setup advanced visual styling with cyberpunk theme"""
        self.visual_theme = {
            'background_primary': "#0a0a0f",
            'background_secondary': "#1a1a2e", 
            'background_tertiary': "#16213e",
            'background_quaternary': "#0f3460",
            'accent_primary': "#00ffff",      # Cyan
            'accent_secondary': "#00ff41",    # Matrix Green
            'accent_tertiary': "#ff6b35",     # Orange
            'accent_quaternary': "#4ecdc4",   # Teal
            'accent_warning': "#ffaa00",      # Amber
            'accent_danger': "#ff3366",       # Red
            'text_primary': "#ffffff",
            'text_secondary': "#cccccc",
            'text_accent': "#00ffff"
        }
        
        style_manager = ttk.Style()
        style_manager.theme_use("clam")
        
        # Title Styles
        style_manager.configure(
            "MainTitle.TLabel",
            background=self.visual_theme['background_primary'],
            foreground=self.visual_theme['accent_primary'],
            font=("Orbitron", 24, "bold"),
            anchor="center"
        )
        
        style_manager.configure(
            "SectionTitle.TLabel",
            background=self.visual_theme['background_secondary'],
            foreground=self.visual_theme['accent_secondary'],
            font=("Consolas", 14, "bold"),
            anchor="w"
        )
        
        # Data Display Styles
        style_manager.configure(
            "MetricValue.TLabel",
            background=self.visual_theme['background_tertiary'],
            foreground=self.visual_theme['text_primary'],
            font=("Consolas", 11),
            anchor="w"
        )
        
        style_manager.configure(
            "MetricLabel.TLabel",
            background=self.visual_theme['background_tertiary'],
            foreground=self.visual_theme['text_secondary'],
            font=("Consolas", 10),
            anchor="w"
        )
        
        # Status Styles
        style_manager.configure(
            "StatusOnline.TLabel",
            background=self.visual_theme['background_quaternary'],
            foreground=self.visual_theme['accent_secondary'],
            font=("Consolas", 12, "bold"),
            anchor="center"
        )
        
        style_manager.configure(
            "StatusOffline.TLabel",
            background=self.visual_theme['background_quaternary'],
            foreground=self.visual_theme['accent_danger'],
            font=("Consolas", 12, "bold"),
            anchor="center"
        )
        
        # Frame Styles
        style_manager.configure(
            "CyberFrame.TFrame",
            background=self.visual_theme['background_secondary'],
            relief="solid",
            borderwidth=1
        )
        
        style_manager.configure(
            "CyberLabelFrame.TLabelframe",
            background=self.visual_theme['background_secondary'],
            foreground=self.visual_theme['accent_primary'],
            relief="solid",
            borderwidth=2
        )

    def _gather_system_information(self):
        """Collect comprehensive system information"""
        system_info = {
            'hostname': socket.gethostname(),
            'platform': platform.platform(),
            'processor': platform.processor(),
            'architecture': platform.architecture()[0],
            'python_version': platform.python_version(),
            'cpu_physical_cores': psutil.cpu_count(logical=False),
            'cpu_logical_cores': psutil.cpu_count(logical=True),
            'boot_time': datetime.fromtimestamp(psutil.boot_time()),
            'uptime': None  # Will be calculated dynamically
        }
        
        try:
            memory_info = psutil.virtual_memory()
            system_info['total_memory_gb'] = round(memory_info.total / (1024**3), 2)
        except:
            system_info['total_memory_gb'] = 0
            
        return system_info

    def _construct_main_dashboard(self):
        """Build the complete dashboard interface"""
        # Main container
        self.main_container = ttk.Frame(self.root_window, style="CyberFrame.TFrame")
        self.main_container.grid(row=0, column=0, sticky="nsew", padx=8, pady=8)
        
        # Configure main container grid
        self.main_container.grid_rowconfigure(1, weight=1)
        self.main_container.grid_rowconfigure(2, weight=2)
        self.main_container.grid_columnconfigure(0, weight=1)
        self.main_container.grid_columnconfigure(1, weight=1)
        self.main_container.grid_columnconfigure(2, weight=1)

        self._create_header_section()
        self._create_system_metrics_panel()
        self._create_api_monitoring_panel()
        self._create_system_information_panel()
        self._create_performance_graphs_panel()

    def _create_header_section(self):
        """Create the main header with title and system overview"""
        header_frame = ttk.Frame(self.main_container, style="CyberFrame.TFrame")
        header_frame.grid(row=0, column=0, columnspan=3, sticky="ew", pady=(0, 10))
        header_frame.grid_columnconfigure(1, weight=1)
        
        # Main title
        title_label = ttk.Label(
            header_frame,
            text="🚀 CYBER TECH SYSTEM MONITOR 🚀",
            style="MainTitle.TLabel"
        )
        title_label.grid(row=0, column=0, columnspan=3, pady=15)
        
        # System status indicators
        status_frame = ttk.Frame(header_frame, style="CyberFrame.TFrame")
        status_frame.grid(row=1, column=0, columnspan=3, pady=10)
        
        self.system_status_label = ttk.Label(
            status_frame,
            text="System Status: Initializing...",
            style="MetricValue.TLabel"
        )
        self.system_status_label.grid(row=0, column=0, padx=20)
        
        self.uptime_label = ttk.Label(
            status_frame,
            text="Uptime: Calculating...",
            style="MetricValue.TLabel"
        )
        self.uptime_label.grid(row=0, column=1, padx=20)
        
        self.alerts_label = ttk.Label(
            status_frame,
            text="🟢 All Systems Normal",
            style="MetricValue.TLabel"
        )
        self.alerts_label.grid(row=0, column=2, padx=20)

    def _create_system_metrics_panel(self):
        """Create comprehensive system metrics display"""
        metrics_frame = ttk.LabelFrame(
            self.main_container,
            text="🖥️ SYSTEM PERFORMANCE METRICS",
            style="CyberLabelFrame.TLabelframe"
        )
        metrics_frame.grid(row=1, column=0, sticky="nsew", padx=(0, 5), pady=5)
        metrics_frame.grid_columnconfigure(0, weight=1)
        
        # CPU Metrics Section
        self._create_cpu_metrics_section(metrics_frame)
        
        # Memory Metrics Section
        self._create_memory_metrics_section(metrics_frame)
        
        # Storage Metrics Section
        self._create_storage_metrics_section(metrics_frame)
        
        # Network Metrics Section
        self._create_network_metrics_section(metrics_frame)
        
        # Process Metrics Section
        self._create_process_metrics_section(metrics_frame)

    def _create_cpu_metrics_section(self, parent_frame):
        """Create detailed CPU monitoring section"""
        cpu_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        cpu_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=8)
        cpu_frame.grid_columnconfigure(1, weight=1)
        cpu_frame.grid_columnconfigure(2, weight=1)
        cpu_frame.grid_columnconfigure(3, weight=1)
        
        ttk.Label(
            cpu_frame,
            text="🔥 PROCESSOR ANALYSIS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 5))
        
        # CPU Usage
        self.cpu_usage_percentage_label = ttk.Label(
            cpu_frame,
            text="Usage: 0.0%",
            style="MetricValue.TLabel"
        )
        self.cpu_usage_percentage_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # CPU Frequency
        self.cpu_frequency_mhz_label = ttk.Label(
            cpu_frame,
            text="Frequency: 0 MHz",
            style="MetricValue.TLabel"
        )
        self.cpu_frequency_mhz_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # CPU Temperature
        self.cpu_temperature_celsius_label = ttk.Label(
            cpu_frame,
            text="Temperature: N/A",
            style="MetricValue.TLabel"
        )
        self.cpu_temperature_celsius_label.grid(row=1, column=2, sticky="w", padx=10)
        
        # CPU Load Average
        self.cpu_load_average_label = ttk.Label(
            cpu_frame,
            text="Load Avg: N/A",
            style="MetricValue.TLabel"
        )
        self.cpu_load_average_label.grid(row=1, column=3, sticky="w", padx=10)
        
        # Additional CPU info
        self.cpu_cores_count_label = ttk.Label(
            cpu_frame,
            text=f"Cores: {self.system_info_cache['cpu_physical_cores']}P/{self.system_info_cache['cpu_logical_cores']}L",
            style="MetricLabel.TLabel"
        )
        self.cpu_cores_count_label.grid(row=2, column=0, sticky="w", padx=(15, 10))
        
        self.cpu_context_switches_label = ttk.Label(
            cpu_frame,
            text="Context Switches: 0",
            style="MetricLabel.TLabel"
        )
        self.cpu_context_switches_label.grid(row=2, column=1, sticky="w", padx=10)
        
        self.cpu_interrupts_label = ttk.Label(
            cpu_frame,
            text="Interrupts: 0",
            style="MetricLabel.TLabel"
        )
        self.cpu_interrupts_label.grid(row=2, column=2, sticky="w", padx=10)

    def _create_memory_metrics_section(self, parent_frame):
        """Create detailed memory monitoring section"""
        memory_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        memory_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=8)
        memory_frame.grid_columnconfigure(1, weight=1)
        memory_frame.grid_columnconfigure(2, weight=1)
        memory_frame.grid_columnconfigure(3, weight=1)
        
        ttk.Label(
            memory_frame,
            text="🧠 MEMORY ANALYSIS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 5))
        
        # Memory Usage Percentage
        self.memory_usage_percentage_label = ttk.Label(
            memory_frame,
            text="Usage: 0.0%",
            style="MetricValue.TLabel"
        )
        self.memory_usage_percentage_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # Memory Total
        self.memory_total_gb_label = ttk.Label(
            memory_frame,
            text=f"Total: {self.system_info_cache['total_memory_gb']} GB",
            style="MetricValue.TLabel"
        )
        self.memory_total_gb_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # Memory Available
        self.memory_available_gb_label = ttk.Label(
            memory_frame,
            text="Available: 0.0 GB",
            style="MetricValue.TLabel"
        )
        self.memory_available_gb_label.grid(row=1, column=2, sticky="w", padx=10)
        
        # Memory Used
        self.memory_used_gb_label = ttk.Label(
            memory_frame,
            text="Used: 0.0 GB",
            style="MetricValue.TLabel"
        )
        self.memory_used_gb_label.grid(row=1, column=3, sticky="w", padx=10)
        
        # Additional memory metrics
        self.memory_cached_gb_label = ttk.Label(
            memory_frame,
            text="Cached: 0.0 GB",
            style="MetricLabel.TLabel"
        )
        self.memory_cached_gb_label.grid(row=2, column=0, sticky="w", padx=(15, 10))
        
        self.memory_buffers_gb_label = ttk.Label(
            memory_frame,
            text="Buffers: 0.0 GB",
            style="MetricLabel.TLabel"
        )
        self.memory_buffers_gb_label.grid(row=2, column=1, sticky="w", padx=10)
        
        self.swap_usage_percentage_label = ttk.Label(
            memory_frame,
            text="Swap: 0.0%",
            style="MetricLabel.TLabel"
        )
        self.swap_usage_percentage_label.grid(row=2, column=2, sticky="w", padx=10)

    def _create_storage_metrics_section(self, parent_frame):
        """Create detailed storage monitoring section"""
        storage_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        storage_frame.grid(row=2, column=0, sticky="ew", padx=10, pady=8)
        storage_frame.grid_columnconfigure(1, weight=1)
        storage_frame.grid_columnconfigure(2, weight=1)
        storage_frame.grid_columnconfigure(3, weight=1)
        
        ttk.Label(
            storage_frame,
            text="💾 STORAGE ANALYSIS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 5))
        
        # Disk Usage Percentage
        self.disk_usage_percentage_label = ttk.Label(
            storage_frame,
            text="Usage: 0.0%",
            style="MetricValue.TLabel"
        )
        self.disk_usage_percentage_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # Disk Total Space
        self.disk_total_gb_label = ttk.Label(
            storage_frame,
            text="Total: 0.0 GB",
            style="MetricValue.TLabel"
        )
        self.disk_total_gb_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # Disk Free Space
        self.disk_free_gb_label = ttk.Label(
            storage_frame,
            text="Free: 0.0 GB",
            style="MetricValue.TLabel"
        )
        self.disk_free_gb_label.grid(row=1, column=2, sticky="w", padx=10)
        
        # Disk I/O
        self.disk_io_read_mb_label = ttk.Label(
            storage_frame,
            text="Read: 0 MB",
            style="MetricValue.TLabel"
        )
        self.disk_io_read_mb_label.grid(row=1, column=3, sticky="w", padx=10)
        
        # Additional storage metrics
        self.disk_io_write_mb_label = ttk.Label(
            storage_frame,
            text="Write: 0 MB",
            style="MetricLabel.TLabel"
        )
        self.disk_io_write_mb_label.grid(row=2, column=0, sticky="w", padx=(15, 10))
        
        self.disk_io_operations_label = ttk.Label(
            storage_frame,
            text="I/O Ops: 0",
            style="MetricLabel.TLabel"
        )
        self.disk_io_operations_label.grid(row=2, column=1, sticky="w", padx=10)

    def _create_network_metrics_section(self, parent_frame):
        """Create detailed network monitoring section"""
        network_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        network_frame.grid(row=3, column=0, sticky="ew", padx=10, pady=8)
        network_frame.grid_columnconfigure(1, weight=1)
        network_frame.grid_columnconfigure(2, weight=1)
        network_frame.grid_columnconfigure(3, weight=1)
        
        ttk.Label(
            network_frame,
            text="🌐 NETWORK ANALYSIS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 5))
        
        # Network Speed
        self.network_speed_mbps_label = ttk.Label(
            network_frame,
            text="Speed: 0.00 MB/s",
            style="MetricValue.TLabel"
        )
        self.network_speed_mbps_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # Upload Speed
        self.network_upload_speed_label = ttk.Label(
            network_frame,
            text="Upload: 0.00 MB/s",
            style="MetricValue.TLabel"
        )
        self.network_upload_speed_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # Download Speed
        self.network_download_speed_label = ttk.Label(
            network_frame,
            text="Download: 0.00 MB/s",
            style="MetricValue.TLabel"
        )
        self.network_download_speed_label.grid(row=1, column=2, sticky="w", padx=10)
        
        # Packets
        self.network_packets_sent_label = ttk.Label(
            network_frame,
            text="Packets Sent: 0",
            style="MetricValue.TLabel"
        )
        self.network_packets_sent_label.grid(row=1, column=3, sticky="w", padx=10)
        
        # Additional network metrics
        self.network_bytes_sent_mb_label = ttk.Label(
            network_frame,
            text="Total Sent: 0.0 MB",
            style="MetricLabel.TLabel"
        )
        self.network_bytes_sent_mb_label.grid(row=2, column=0, sticky="w", padx=(15, 10))
        
        self.network_bytes_received_mb_label = ttk.Label(
            network_frame,
            text="Total Received: 0.0 MB",
            style="MetricLabel.TLabel"
        )
        self.network_bytes_received_mb_label.grid(row=2, column=1, sticky="w", padx=10)
        
        self.network_connections_count_label = ttk.Label(
            network_frame,
            text="Connections: 0",
            style="MetricLabel.TLabel"
        )
        self.network_connections_count_label.grid(row=2, column=2, sticky="w", padx=10)

    def _create_process_metrics_section(self, parent_frame):
        """Create process monitoring section"""
        process_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        process_frame.grid(row=4, column=0, sticky="ew", padx=10, pady=8)
        process_frame.grid_columnconfigure(1, weight=1)
        process_frame.grid_columnconfigure(2, weight=1)
        
        ttk.Label(
            process_frame,
            text="⚡ PROCESS ANALYSIS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=3, sticky="w", pady=(0, 5))
        
        # Process Count
        self.process_count_total_label = ttk.Label(
            process_frame,
            text="Total Processes: 0",
            style="MetricValue.TLabel"
        )
        self.process_count_total_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # Running Processes
        self.process_count_running_label = ttk.Label(
            process_frame,
            text="Running: 0",
            style="MetricValue.TLabel"
        )
        self.process_count_running_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # Sleeping Processes
        self.process_count_sleeping_label = ttk.Label(
            process_frame,
            text="Sleeping: 0",
            style="MetricValue.TLabel"
        )
        self.process_count_sleeping_label.grid(row=1, column=2, sticky="w", padx=10)

    def _create_api_monitoring_panel(self):
        """Create comprehensive API monitoring panel"""
        api_frame = ttk.LabelFrame(
            self.main_container,
            text="🔗 API MONITORING & ENDPOINT DISCOVERY",
            style="CyberLabelFrame.TLabelframe"
        )
        api_frame.grid(row=1, column=1, sticky="nsew", padx=5, pady=5)
        api_frame.grid_columnconfigure(0, weight=1)
        api_frame.grid_rowconfigure(4, weight=1)

        # API Status Section
        self._create_api_status_section(api_frame)
        
        # API Configuration Section
        self._create_api_configuration_section(api_frame)
        
        # Endpoints Discovery Section
        self._create_endpoints_section(api_frame)
        
        # API Logs Section
        self._create_api_logs_section(api_frame)

    def _create_api_status_section(self, parent_frame):
        """Create API status monitoring section"""
        status_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        status_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=8)
        status_frame.grid_columnconfigure(1, weight=1)
        status_frame.grid_columnconfigure(2, weight=1)
        
        ttk.Label(
            status_frame,
            text="📡 CONNECTION STATUS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=3, sticky="w", pady=(0, 5))
        
        # API Status
        self.api_connection_status_label = ttk.Label(
            status_frame,
            text="Status: 🔍 INITIALIZING",
            style="StatusOnline.TLabel"
        )
        self.api_connection_status_label.grid(row=1, column=0, sticky="w", padx=(15, 10))
        
        # Response Time
        self.api_response_time_ms_label = ttk.Label(
            status_frame,
            text="Response: 0ms",
            style="MetricValue.TLabel"
        )
        self.api_response_time_ms_label.grid(row=1, column=1, sticky="w", padx=10)
        
        # Success Rate
        self.api_success_rate_label = ttk.Label(
            status_frame,
            text="Success Rate: 100%",
            style="MetricValue.TLabel"
        )
        self.api_success_rate_label.grid(row=1, column=2, sticky="w", padx=10)
        
        # Last Check Time
        self.api_last_check_timestamp_label = ttk.Label(
            status_frame,
            text="Last Check: System Starting",
            style="MetricLabel.TLabel"
        )
        self.api_last_check_timestamp_label.grid(row=2, column=0, columnspan=3, sticky="w", padx=(15, 0))

    def _create_api_configuration_section(self, parent_frame):
        """Create API configuration section"""
        config_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        config_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=8)
        config_frame.grid_columnconfigure(0, weight=1)
        
        ttk.Label(
            config_frame,
            text="🎯 ENDPOINT CONFIGURATION",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 5))
        
        # URL Entry
        url_input_frame = ttk.Frame(config_frame, style="CyberFrame.TFrame")
        url_input_frame.grid(row=1, column=0, sticky="ew", padx=(15, 0))
        url_input_frame.grid_columnconfigure(0, weight=1)
        
        self.api_base_url_entry = tk.Entry(
            url_input_frame,
            bg=self.visual_theme['background_tertiary'],
            fg=self.visual_theme['text_primary'],
            font=("Consolas", 10),
            insertbackground=self.visual_theme['accent_primary']
        )
        self.api_base_url_entry.grid(row=0, column=0, sticky="ew", padx=(0, 10), pady=5)
        self.api_base_url_entry.insert(0, self.api_base_url)
        
        self.api_url_update_button = tk.Button(
            url_input_frame,
            text="🔄 Update URL",
            command=self._handle_api_url_update,
            bg=self.visual_theme['accent_secondary'],
            fg=self.visual_theme['background_primary'],
            font=("Consolas", 9, "bold"),
            relief="flat",
            cursor="hand2"
        )
        self.api_url_update_button.grid(row=0, column=1, pady=5)

    def _create_endpoints_section(self, parent_frame):
        """Create endpoints discovery section"""
        endpoints_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        endpoints_frame.grid(row=2, column=0, sticky="ew", padx=10, pady=8)
        endpoints_frame.grid_columnconfigure(0, weight=1)
        
        ttk.Label(
            endpoints_frame,
            text="🛤️ DISCOVERED ENDPOINTS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, sticky="w", pady=(0, 5))
        
        # Endpoints Display
        endpoints_display_frame = ttk.Frame(endpoints_frame, style="CyberFrame.TFrame")
        endpoints_display_frame.grid(row=1, column=0, sticky="ew", padx=(15, 0))
        endpoints_display_frame.grid_columnconfigure(0, weight=1)
        
        self.api_endpoints_display = tk.Text(
            endpoints_display_frame,
            height=6,
            bg=self.visual_theme['background_tertiary'],
            fg=self.visual_theme['accent_quaternary'],
            font=("Consolas", 9),
            wrap=tk.WORD,
            relief="flat",
            cursor="arrow"
        )
        self.api_endpoints_display.grid(row=0, column=0, sticky="ew", pady=5)

    def _create_api_logs_section(self, parent_frame):
        """Create API monitoring logs section"""
        logs_frame = ttk.Frame(parent_frame, style="CyberFrame.TFrame")
        logs_frame.grid(row=3, column=0, sticky="nsew", padx=10, pady=8)
        logs_frame.grid_columnconfigure(0, weight=1)
        logs_frame.grid_rowconfigure(1, weight=1)
        
        ttk.Label(
            logs_frame,
            text="📋 MONITORING LOGS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, sticky="w", pady=(0, 5))
        
        # Logs Display with Scrollbar
        logs_container = ttk.Frame(logs_frame)
        logs_container.grid(row=1, column=0, sticky="nsew", padx=(15, 0))
        logs_container.grid_columnconfigure(0, weight=1)
        logs_container.grid_rowconfigure(0, weight=1)
        
        self.api_monitoring_logs = tk.Text(
            logs_container,
            height=12,
            bg=self.visual_theme['background_quaternary'],
            fg=self.visual_theme['text_primary'],
            font=("Consolas", 9),
            wrap=tk.WORD,
            relief="flat"
        )
        
        logs_scrollbar = ttk.Scrollbar(
            logs_container,
            orient=tk.VERTICAL,
            command=self.api_monitoring_logs.yview
        )
        
        self.api_monitoring_logs.configure(yscrollcommand=logs_scrollbar.set)
        self.api_monitoring_logs.grid(row=0, column=0, sticky="nsew")
        logs_scrollbar.grid(row=0, column=1, sticky="ns")

    def _create_system_information_panel(self):
        """Create system information panel"""
        info_frame = ttk.LabelFrame(
            self.main_container,
            text="📊 SYSTEM INFORMATION",
            style="CyberLabelFrame.TLabelframe"
        )
        info_frame.grid(row=1, column=2, sticky="nsew", padx=(5, 0), pady=5)
        info_frame.grid_columnconfigure(0, weight=1)
        
        # System Details
        details_frame = ttk.Frame(info_frame, style="CyberFrame.TFrame")
        details_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=8)
        details_frame.grid_columnconfigure(1, weight=1)
        
        ttk.Label(
            details_frame,
            text="🖥️ SYSTEM DETAILS",
            style="SectionTitle.TLabel"
        ).grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 10))
        
        # Hostname
        ttk.Label(details_frame, text="Hostname:", style="MetricLabel.TLabel").grid(
            row=1, column=0, sticky="w", padx=(15, 5)
        )
        ttk.Label(
            details_frame,
            text=self.system_info_cache['hostname'],
            style="MetricValue.TLabel"
        ).grid(row=1, column=1, sticky="w")
        
        # Platform
        ttk.Label(details_frame, text="Platform:", style="MetricLabel.TLabel").grid(
            row=2, column=0, sticky="w", padx=(15, 5)
        )
        platform_text = self.system_info_cache['platform'][:40] + "..." if len(self.system_info_cache['platform']) > 40 else self.system_info_cache['platform']
        ttk.Label(
            details_frame,
            text=platform_text,
            style="MetricValue.TLabel"
        ).grid(row=2, column=1, sticky="w")
        
        # Architecture
        ttk.Label(details_frame, text="Architecture:", style="MetricLabel.TLabel").grid(
            row=3, column=0, sticky="w", padx=(15, 5)
        )
        ttk.Label(
            details_frame,
            text=self.system_info_cache['architecture'],
            style="MetricValue.TLabel"
        ).grid(row=3, column=1, sticky="w")
        
        # Python Version
        ttk.Label(details_frame, text="Python:", style="MetricLabel.TLabel").grid(
            row=4, column=0, sticky="w", padx=(15, 5)
        )
        ttk.Label(
            details_frame,
            text=self.system_info_cache['python_version'],
            style="MetricValue.TLabel"
        ).grid(row=4, column=1, sticky="w")
        
        # Boot Time
        ttk.Label(details_frame, text="Boot Time:", style="MetricLabel.TLabel").grid(
            row=5, column=0, sticky="w", padx=(15, 5)
        )
        ttk.Label(
            details_frame,
            text=self.system_info_cache['boot_time'].strftime("%Y-%m-%d %H:%M:%S"),
            style="MetricValue.TLabel"
        ).grid(row=5, column=1, sticky="w")

    def _create_performance_graphs_panel(self):
        """Create advanced performance visualization panel"""
        graphs_frame = ttk.LabelFrame(
            self.main_container,
            text="📈 REAL-TIME PERFORMANCE ANALYTICS",
            style="CyberLabelFrame.TLabelframe"
        )
        graphs_frame.grid(row=2, column=0, columnspan=3, sticky="nsew", pady=10)
        graphs_frame.grid_columnconfigure(0, weight=1)
        graphs_frame.grid_rowconfigure(0, weight=1)
        
        # Configure matplotlib for dark theme
        plt.style.use('dark_background')
        
        # Create figure with subplots
        self.performance_figure = Figure(figsize=(18, 8), facecolor=self.visual_theme['background_secondary'])
        self.performance_figure.suptitle(
            "System Performance Metrics - Real-Time Monitoring",
            color=self.visual_theme['accent_primary'],
            fontsize=16,
            fontweight="bold"
        )
        
        # Create subplots
        self.cpu_usage_plot = self.performance_figure.add_subplot(231, facecolor=self.visual_theme['background_tertiary'])
        self.memory_usage_plot = self.performance_figure.add_subplot(232, facecolor=self.visual_theme['background_tertiary'])
        self.disk_usage_plot = self.performance_figure.add_subplot(233, facecolor=self.visual_theme['background_tertiary'])
        self.network_speed_plot = self.performance_figure.add_subplot(234, facecolor=self.visual_theme['background_tertiary'])
        self.temperature_plot = self.performance_figure.add_subplot(235, facecolor=self.visual_theme['background_tertiary'])
        self.system_load_plot = self.performance_figure.add_subplot(236, facecolor=self.visual_theme['background_tertiary'])
        
        # Configure plot styles
        all_plots = [
            self.cpu_usage_plot, self.memory_usage_plot, self.disk_usage_plot,
            self.network_speed_plot, self.temperature_plot, self.system_load_plot
        ]
        
        plot_titles = [
            "CPU Usage (%)", "Memory Usage (%)", "Disk Usage (%)",
            "Network Speed (MB/s)", "Temperature (°C)", "System Load"
        ]
        
        plot_colors = [
            self.visual_theme['accent_secondary'],  # Green
            self.visual_theme['accent_tertiary'],   # Orange
            self.visual_theme['accent_quaternary'], # Teal
            self.visual_theme['accent_primary'],    # Cyan
            self.visual_theme['accent_warning'],    # Amber
            self.visual_theme['accent_danger']      # Red
        ]
        
        for i, (plot, title, color) in enumerate(zip(all_plots, plot_titles, plot_colors)):
            plot.set_title(title, color=self.visual_theme['accent_primary'], fontweight="bold", fontsize=10)
            plot.tick_params(colors=self.visual_theme['text_primary'], labelsize=8)
            plot.grid(True, alpha=0.3, color=self.visual_theme['text_secondary'])
            
            # Style spines
            for spine in plot.spines.values():
                spine.set_color(color)
                spine.set_linewidth(1.5)
        
        # Create canvas
        self.performance_canvas = FigureCanvasTkAgg(self.performance_figure, master=graphs_frame)
        self.performance_canvas.get_tk_widget().grid(row=0, column=0, sticky="nsew", padx=10, pady=10)
        
        # Animation for real-time updates
        self.performance_animation = animation.FuncAnimation(
            self.performance_figure,
            self._update_performance_graphs,
            interval=self.update_interval_ms,
            blit=False,
            cache_frame_data=False
        )

    def _initialize_monitoring_systems(self):
        """Initialize all monitoring systems and threads"""
        self._log_system_message("🚀 Initializing Cyber Tech System Monitor...")
        self._log_system_message(f"📊 System: {self.system_info_cache['hostname']} | {self.system_info_cache['platform']}")
        
        # Start hardware monitoring
        self._schedule_hardware_monitoring()
        
        # Start API monitoring
        self._start_api_monitoring_thread()
        
        self._log_system_message("✅ All monitoring systems initialized successfully!")

    def _schedule_hardware_monitoring(self):
        """Schedule periodic hardware monitoring updates"""
        try:
            hardware_metrics = self._collect_hardware_metrics()
            self._update_hardware_display(hardware_metrics)
            self._update_system_alerts(hardware_metrics)
            self._update_system_status()
        except Exception as system_error:
            self._log_system_message(f"❌ Hardware monitoring error: {system_error}")
        
        # Schedule next update
        self.root_window.after(self.update_interval_ms, self._schedule_hardware_monitoring)

    def _collect_hardware_metrics(self):
        """Collect comprehensive hardware performance metrics"""
        current_timestamp = time.time()
        
        # CPU Metrics
        cpu_usage_percentage = psutil.cpu_percent(interval=None)
        cpu_frequency_info = psutil.cpu_freq()
        cpu_frequency_mhz = cpu_frequency_info.current if cpu_frequency_info else 0
        
        try:
            cpu_load_average = os.getloadavg()[0] if hasattr(os, 'getloadavg') else 0
        except:
            cpu_load_average = 0
        
        # CPU Stats
        try:
            cpu_stats = psutil.cpu_stats()
            cpu_context_switches = cpu_stats.ctx_switches
            cpu_interrupts = cpu_stats.interrupts
        except:
            cpu_context_switches = 0
            cpu_interrupts = 0
        
        # Memory Metrics
        memory_info = psutil.virtual_memory()
        memory_usage_percentage = memory_info.percent
        memory_total_gb = memory_info.total / (1024**3)
        memory_available_gb = memory_info.available / (1024**3)
        memory_used_gb = memory_info.used / (1024**3)
        
        try:
            memory_cached_gb = getattr(memory_info, 'cached', 0) / (1024**3)
            memory_buffers_gb = getattr(memory_info, 'buffers', 0) / (1024**3)
        except:
            memory_cached_gb = 0
            memory_buffers_gb = 0
        
        # Swap Memory
        try:
            swap_info = psutil.swap_memory()
            swap_usage_percentage = swap_info.percent
        except:
            swap_usage_percentage = 0
        
        # Storage Metrics
        disk_usage_info = psutil.disk_usage("/")
        disk_usage_percentage = disk_usage_info.percent
        disk_total_gb = disk_usage_info.total / (1024**3)
        disk_free_gb = disk_usage_info.free / (1024**3)
        
        # Disk I/O
        try:
            disk_io_info = psutil.disk_io_counters()
            disk_io_read_mb = disk_io_info.read_bytes / (1024**2)
            disk_io_write_mb = disk_io_info.write_bytes / (1024**2)
            disk_io_operations = disk_io_info.read_count + disk_io_info.write_count
        except:
            disk_io_read_mb = 0
            disk_io_write_mb = 0
            disk_io_operations = 0
        
        # Network Metrics
        network_io_info = psutil.net_io_counters()
        network_bytes_sent_mb = network_io_info.bytes_sent / (1024**2)
        network_bytes_received_mb = network_io_info.bytes_recv / (1024**2)
        network_packets_sent = network_io_info.packets_sent
        
        # Calculate network speed
        network_speed_mbps = 0.0
        upload_speed_mbps = 0.0
        download_speed_mbps = 0.0
        
        if self.network_monitoring_state['previous_bytes_total'] is not None:
            previous_total = self.network_monitoring_state['previous_bytes_total']
            previous_timestamp = self.network_monitoring_state['previous_timestamp']
            
            current_total = network_io_info.bytes_sent + network_io_info.bytes_recv
            time_delta = max(0.1, current_timestamp - previous_timestamp)
            
            network_speed_mbps = (current_total - previous_total) / (1024**2) / time_delta
            upload_speed_mbps = (network_io_info.bytes_sent - self.network_monitoring_state.get('prev_sent', 0)) / (1024**2) / time_delta
            download_speed_mbps = (network_io_info.bytes_recv - self.network_monitoring_state.get('prev_recv', 0)) / (1024**2) / time_delta
        
        # Update network monitoring state
        self.network_monitoring_state.update({
            'previous_bytes_total': network_io_info.bytes_sent + network_io_info.bytes_recv,
            'previous_timestamp': current_timestamp,
            'prev_sent': network_io_info.bytes_sent,
            'prev_recv': network_io_info.bytes_recv,
            'current_download_speed_mbps': max(0, download_speed_mbps),
            'current_upload_speed_mbps': max(0, upload_speed_mbps)
        })
        
        # Network Connections
        try:
            network_connections_count = len(psutil.net_connections())
        except:
            network_connections_count = 0
        
        # Process Metrics
        all_processes = list(psutil.process_iter(['status']))
        process_count_total = len(all_processes)
        process_count_running = sum(1 for p in all_processes if p.info['status'] == psutil.STATUS_RUNNING)
        process_count_sleeping = sum(1 for p in all_processes if p.info['status'] == psutil.STATUS_SLEEPING)
        
        # Temperature (best effort)
        cpu_temperature_celsius = "N/A"
        system_temperature_value = 0
        try:
            temperature_sensors = psutil.sensors_temperatures()
            if temperature_sensors:
                # Get first available temperature
                first_sensor = list(temperature_sensors.values())[0]
                if first_sensor:
                    temp_value = first_sensor[0].current
                    cpu_temperature_celsius = f"{temp_value:.1f}°C"
                    system_temperature_value = temp_value
        except:
            pass
        
        # Store data for graphs
        self.system_metrics['cpu_usage_percentage'].append(cpu_usage_percentage)
        self.system_metrics['memory_usage_percentage'].append(memory_usage_percentage)
        self.system_metrics['disk_usage_percentage'].append(disk_usage_percentage)
        self.system_metrics['network_speed_mbps'].append(max(0, network_speed_mbps))
        self.system_metrics['system_temperature_celsius'].append(system_temperature_value)
        
        return {
            'cpu': {
                'usage_percentage': cpu_usage_percentage,
                'frequency_mhz': cpu_frequency_mhz,
                'temperature_celsius': cpu_temperature_celsius,
                'load_average': cpu_load_average,
                'context_switches': cpu_context_switches,
                'interrupts': cpu_interrupts
            },
            'memory': {
                'usage_percentage': memory_usage_percentage,
                'total_gb': memory_total_gb,
                'available_gb': memory_available_gb,
                'used_gb': memory_used_gb,
                'cached_gb': memory_cached_gb,
                'buffers_gb': memory_buffers_gb,
                'swap_usage_percentage': swap_usage_percentage
            },
            'storage': {
                'usage_percentage': disk_usage_percentage,
                'total_gb': disk_total_gb,
                'free_gb': disk_free_gb,
                'io_read_mb': disk_io_read_mb,
                'io_write_mb': disk_io_write_mb,
                'io_operations': disk_io_operations
            },
            'network': {
                'speed_mbps': network_speed_mbps,
                'upload_speed_mbps': upload_speed_mbps,
                'download_speed_mbps': download_speed_mbps,
                'bytes_sent_mb': network_bytes_sent_mb,
                'bytes_received_mb': network_bytes_received_mb,
                'packets_sent': network_packets_sent,
                'connections_count': network_connections_count
            },
            'processes': {
                'total_count': process_count_total,
                'running_count': process_count_running,
                'sleeping_count': process_count_sleeping
            },
            'system_temperature_value': system_temperature_value
        }

    def _update_hardware_display(self, metrics):
        """Update all hardware metric displays"""
        # CPU Updates
        self.cpu_usage_percentage_label.config(text=f"Usage: {metrics['cpu']['usage_percentage']:.1f}%")
        self.cpu_frequency_mhz_label.config(text=f"Frequency: {metrics['cpu']['frequency_mhz']:.0f} MHz")
        self.cpu_temperature_celsius_label.config(text=f"Temperature: {metrics['cpu']['temperature_celsius']}")
        self.cpu_load_average_label.config(text=f"Load Avg: {metrics['cpu']['load_average']:.2f}")
        self.cpu_context_switches_label.config(text=f"Context Switches: {metrics['cpu']['context_switches']:,}")
        self.cpu_interrupts_label.config(text=f"Interrupts: {metrics['cpu']['interrupts']:,}")
        
        # Memory Updates
        self.memory_usage_percentage_label.config(text=f"Usage: {metrics['memory']['usage_percentage']:.1f}%")
        self.memory_available_gb_label.config(text=f"Available: {metrics['memory']['available_gb']:.1f} GB")
        self.memory_used_gb_label.config(text=f"Used: {metrics['memory']['used_gb']:.1f} GB")
        self.memory_cached_gb_label.config(text=f"Cached: {metrics['memory']['cached_gb']:.1f} GB")
        self.memory_buffers_gb_label.config(text=f"Buffers: {metrics['memory']['buffers_gb']:.1f} GB")
        self.swap_usage_percentage_label.config(text=f"Swap: {metrics['memory']['swap_usage_percentage']:.1f}%")
        
        # Storage Updates
        self.disk_usage_percentage_label.config(text=f"Usage: {metrics['storage']['usage_percentage']:.1f}%")
        self.disk_total_gb_label.config(text=f"Total: {metrics['storage']['total_gb']:.1f} GB")
        self.disk_free_gb_label.config(text=f"Free: {metrics['storage']['free_gb']:.1f} GB")
        self.disk_io_read_mb_label.config(text=f"Read: {metrics['storage']['io_read_mb']:.0f} MB")
        self.disk_io_write_mb_label.config(text=f"Write: {metrics['storage']['io_write_mb']:.0f} MB")
        self.disk_io_operations_label.config(text=f"I/O Ops: {metrics['storage']['io_operations']:,}")
        
        # Network Updates
        self.network_speed_mbps_label.config(text=f"Speed: {metrics['network']['speed_mbps']:.2f} MB/s")
        self.network_upload_speed_label.config(text=f"Upload: {metrics['network']['upload_speed_mbps']:.2f} MB/s")
        self.network_download_speed_label.config(text=f"Download: {metrics['network']['download_speed_mbps']:.2f} MB/s")
        self.network_packets_sent_label.config(text=f"Packets Sent: {metrics['network']['packets_sent']:,}")
        self.network_bytes_sent_mb_label.config(text=f"Total Sent: {metrics['network']['bytes_sent_mb']:.1f} MB")
        self.network_bytes_received_mb_label.config(text=f"Total Received: {metrics['network']['bytes_received_mb']:.1f} MB")
        self.network_connections_count_label.config(text=f"Connections: {metrics['network']['connections_count']}")
        
        # Process Updates
        self.process_count_total_label.config(text=f"Total Processes: {metrics['processes']['total_count']}")
        self.process_count_running_label.config(text=f"Running: {metrics['processes']['running_count']}")
        self.process_count_sleeping_label.config(text=f"Sleeping: {metrics['processes']['sleeping_count']}")

    def _update_system_alerts(self, metrics):
        """Check for system performance alerts"""
        current_alerts = set()
        
        # CPU Alert
        if metrics['cpu']['usage_percentage'] > self.performance_alerts['cpu_high_usage_threshold']:
            current_alerts.add(f"🔥 High CPU Usage: {metrics['cpu']['usage_percentage']:.1f}%")
        
        # Memory Alert
        if metrics['memory']['usage_percentage'] > self.performance_alerts['memory_high_usage_threshold']:
            current_alerts.add(f"🧠 High Memory Usage: {metrics['memory']['usage_percentage']:.1f}%")
        
        # Disk Alert
        if metrics['storage']['usage_percentage'] > self.performance_alerts['disk_high_usage_threshold']:
            current_alerts.add(f"💾 High Disk Usage: {metrics['storage']['usage_percentage']:.1f}%")
        
        # Temperature Alert
        if (metrics['system_temperature_value'] > 0 and 
            metrics['system_temperature_value'] > self.performance_alerts['temperature_high_threshold']):
            current_alerts.add(f"🌡️ High Temperature: {metrics['system_temperature_value']:.1f}°C")
        
        # Update alerts display
        if current_alerts != self.performance_alerts['active_alerts']:
            self.performance_alerts['active_alerts'] = current_alerts
            
            if current_alerts:
                alert_text = " | ".join(list(current_alerts)[:2])  # Show max 2 alerts
                self.alerts_label.config(text=f"⚠️ {alert_text}", foreground=self.visual_theme['accent_warning'])
            else:
                self.alerts_label.config(text="🟢 All Systems Normal", foreground=self.visual_theme['accent_secondary'])

    def _update_system_status(self):
        """Update system status and uptime"""
        # Calculate uptime
        current_time = datetime.now()
        uptime_duration = current_time - self.system_info_cache['boot_time']
        
        days = uptime_duration.days
        hours, remainder = divmod(uptime_duration.seconds, 3600)
        minutes, _ = divmod(remainder, 60)
        
        uptime_text = f"Uptime: {days}d {hours}h {minutes}m"
        self.uptime_label.config(text=uptime_text)
        
        # System status
        status_text = "System Status: 🟢 Operational"
        self.system_status_label.config(text=status_text)

    def _start_api_monitoring_thread(self):
        """Start API monitoring in separate thread"""
        # Initial endpoint discovery
        threading.Thread(target=self._discover_api_endpoints, daemon=True).start()
        
        # Periodic status checks
        def periodic_api_monitoring():
            threading.Thread(target=self._check_api_connection_status, daemon=True).start()
            self.root_window.after(self.api_check_interval_ms, periodic_api_monitoring)
        
        periodic_api_monitoring()

    def _check_api_connection_status(self):
        """Check API connection status and response time"""
        try:
            request_start_time = time.time()
            api_response = requests.get(f"{self.api_base_url}/", timeout=5)
            response_time_ms = (time.time() - request_start_time) * 1000.0
            
            if api_response.status_code == 200:
                connection_status = "🟢 ONLINE"
                status_color = self.visual_theme['accent_secondary']
                self.api_monitoring_state['success_count'] += 1
                log_message = f"✅ API Online - Response: {response_time_ms:.0f}ms"
            else:
                connection_status = f"🟡 ERROR {api_response.status_code}"
                status_color = self.visual_theme['accent_warning']
                self.api_monitoring_state['error_count'] += 1
                log_message = f"⚠️ API Error {api_response.status_code} - Response: {response_time_ms:.0f}ms"
                
        except requests.exceptions.RequestException as connection_error:
            connection_status = "🔴 OFFLINE"
            status_color = self.visual_theme['accent_danger']
            response_time_ms = 0
            self.api_monitoring_state['error_count'] += 1
            log_message = f"❌ API Offline - {str(connection_error)[:50]}..."
        
        # Update API monitoring state
        self.api_monitoring_state.update({
            'connection_status': connection_status,
            'response_time_ms': response_time_ms,
            'last_check_timestamp': datetime.now().strftime("%H:%M:%S"),
            'status_color': status_color
        })
        
        # Update UI in main thread
        def update_api_display():
            self.api_connection_status_label.config(
                text=f"Status: {self.api_monitoring_state['connection_status']}",
                foreground=self.api_monitoring_state['status_color']
            )
            self.api_response_time_ms_label.config(
                text=f"Response: {self.api_monitoring_state['response_time_ms']:.0f}ms"
            )
            self.api_last_check_timestamp_label.config(
                text=f"Last Check: {self.api_monitoring_state['last_check_timestamp']}"
            )
            
            # Update success rate
            total_checks = self.api_monitoring_state['success_count'] + self.api_monitoring_state['error_count']
            if total_checks > 0:
                success_rate = (self.api_monitoring_state['success_count'] / total_checks) * 100
                self.api_success_rate_label.config(text=f"Success Rate: {success_rate:.1f}%")
            
            self._log_system_message(log_message)
        
        self.root_window.after(0, update_api_display)

    def _discover_api_endpoints(self):
        """Discover available API endpoints"""
        discovered_endpoints = []
        
        # Try dedicated routes endpoint
        try:
            routes_response = requests.get(f"{self.api_base_url}/routes", timeout=3)
            if routes_response.status_code == 200:
                routes_data = routes_response.json()
                if isinstance(routes_data, list):
                    discovered_endpoints.extend([f"✅ {route}" for route in routes_data])
        except Exception:
            pass
        
        # Test common endpoints
        common_endpoints = [
            "/", "/health", "/status", "/api", "/docs", "/swagger", 
            "/routes", "/info", "/version", "/ping", "/metrics"
        ]
        
        for endpoint in common_endpoints:
            try:
                endpoint_response = requests.head(f"{self.api_base_url}{endpoint}", timeout=2)
                if endpoint_response.status_code < 400:
                    status_icon = "✅" if endpoint_response.status_code == 200 else "⚠️"
                    discovered_endpoints.append(f"{status_icon} {endpoint} [{endpoint_response.status_code}]")
            except Exception:
                pass
        
        # Update UI in main thread
        def update_endpoints_display():
            self.api_monitoring_state['available_endpoints'] = discovered_endpoints
            self.api_endpoints_display.delete("1.0", tk.END)
            
            if discovered_endpoints:
                endpoints_text = "\n".join(discovered_endpoints)
                self.api_endpoints_display.insert(tk.END, endpoints_text)
            else:
                self.api_endpoints_display.insert(tk.END, 
                    "❌ No endpoints discovered\n\n"
                    "💡 Tips:\n"
                    "• Ensure API server is running\n"
                    "• Add /routes endpoint to your Flask app\n"
                    "• Check firewall settings"
                )
        
        self.root_window.after(0, update_endpoints_display)

    def _handle_api_url_update(self):
        """Handle API URL update from user input"""
        new_api_url = self.api_base_url_entry.get().strip()
        if new_api_url and new_api_url != self.api_base_url:
            self.api_base_url = new_api_url
            self._log_system_message(f"🔄 API URL updated to: {self.api_base_url}")
            
            # Reset API monitoring state
            self.api_monitoring_state.update({
                'error_count': 0,
                'success_count': 0,
                'available_endpoints': []
            })
            
            # Restart API monitoring
            threading.Thread(target=self._discover_api_endpoints, daemon=True).start()
            threading.Thread(target=self._check_api_connection_status, daemon=True).start()

    def _log_system_message(self, message):
        """Add message to system logs with timestamp"""
        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]  # Include milliseconds
        log_entry = f"[{timestamp}] {message}\n"
        
        self.api_monitoring_logs.insert(tk.END, log_entry)
        self.api_monitoring_logs.see(tk.END)
        
        # Keep log size manageable
        if int(self.api_monitoring_logs.index('end-1c').split('.')[0]) > 200:
            self.api_monitoring_logs.delete("1.0", "50.0")

    def _update_performance_graphs(self, frame_number):
        """Update all performance graphs with latest data"""
        try:
            # Clear all plots
            plots_and_data = [
                (self.cpu_usage_plot, self.system_metrics['cpu_usage_percentage'], "CPU Usage (%)", 0, 100),
                (self.memory_usage_plot, self.system_metrics['memory_usage_percentage'], "Memory Usage (%)", 0, 100),
                (self.disk_usage_plot, self.system_metrics['disk_usage_percentage'], "Disk Usage (%)", 0, 100),
                (self.network_speed_plot, self.system_metrics['network_speed_mbps'], "Network Speed (MB/s)", 0, None),
                (self.temperature_plot, self.system_metrics['system_temperature_celsius'], "Temperature (°C)", 0, None),
                (self.system_load_plot, self.system_metrics['cpu_usage_percentage'], "System Load", 0, 100)  # Reuse CPU data
            ]
            
            plot_colors = [
                self.visual_theme['accent_secondary'],  # Green
                self.visual_theme['accent_tertiary'],   # Orange
                self.visual_theme['accent_quaternary'], # Teal
                self.visual_theme['accent_primary'],    # Cyan
                self.visual_theme['accent_warning'],    # Amber
                self.visual_theme['accent_danger']      # Red
            ]
            
            for i, ((plot, data, title, y_min, y_max), color) in enumerate(zip(plots_and_data, plot_colors)):
                plot.clear()
                
                if len(data) > 1:
                    x_values = range(len(data))
                    y_values = list(data)
                    
                    # Plot line with gradient fill
                    plot.plot(x_values, y_values, linewidth=2.5, color=color, alpha=0.9)
                    plot.fill_between(x_values, y_values, alpha=0.3, color=color)
                    
                    # Set axis limits
                    if y_max is not None:
                        plot.set_ylim(y_min, y_max)
                    else:
                        plot.set_ylim(y_min, max(max(y_values) * 1.1, 1))
                
                # Restore styling
                plot.set_title(title, color=self.visual_theme['accent_primary'], fontweight="bold", fontsize=10)
                plot.set_facecolor(self.visual_theme['background_tertiary'])
                plot.tick_params(colors=self.visual_theme['text_primary'], labelsize=8)
                plot.grid(True, alpha=0.3, color=self.visual_theme['text_secondary'])
                
                for spine in plot.spines.values():
                    spine.set_color(color)
                    spine.set_linewidth(1.5)
            
            # Adjust layout
            self.performance_figure.tight_layout(rect=[0, 0.03, 1, 0.95])
            
        except Exception:
            # Silent error handling to prevent animation interruption
            pass


def initialize_cyber_tech_monitor():
    """Initialize and run the Cyber Tech System Monitor"""
    print("🚀 Initializing Cyber Tech System Monitor...")
    print("📊 Advanced System & API Monitoring Dashboard")
    print("⚡ Real-time Performance Analytics")
    print("-" * 50)
    
    root_application = tk.Tk()
    
    # Set default API URL (can be customized)
    default_api_url = "http://127.0.0.1:5000"
    
    # Create monitor instance
    monitor_dashboard = CyberTechSystemMonitor(
        root_window=root_application,
        api_base_url=default_api_url
    )
    
    try:
        print("✅ Dashboard initialized successfully!")
        print("🌐 Access your API monitoring at the configured URL")
        print("📈 Real-time graphs updating every second")
        print("🔍 Press Ctrl+C to exit gracefully")
        print("-" * 50)
        
        root_application.mainloop()
        
    except KeyboardInterrupt:
        print("\n🛑 Dashboard shutdown requested by user")
        print("✅ Cyber Tech System Monitor closed gracefully")
    except Exception as startup_error:
        print(f"❌ Dashboard startup error: {startup_error}")
    finally:
        print("👋 Thank you for using Cyber Tech System Monitor!")


if __name__ == "__main__":
    initialize_cyber_tech_monitor()