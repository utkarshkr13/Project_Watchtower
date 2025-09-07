#!/usr/bin/env python3
"""
FWB Device Testing Manager
=========================

Manages iOS simulators and Android emulators for automated testing.
Integrates with Xcode and Android Studio for device creation and management.
"""

import asyncio
import json
import logging
import os
import subprocess
import time
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple
import uuid
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class DeviceSpec:
    """Device specification for testing"""
    id: str
    name: str
    platform: str  # 'ios' or 'android'
    version: str
    device_type: str
    udid: Optional[str] = None
    port: Optional[int] = None
    status: str = "stopped"  # stopped, starting, running, error

class iOSSimulatorManager:
    """Manages iOS simulators using Xcode simctl"""
    
    def __init__(self):
        self.simulators = {}
        self.default_devices = [
            {"name": "iPhone 15 Pro", "type": "iPhone15,2", "runtime": "iOS-17-0"},
            {"name": "iPhone 16 Pro", "type": "iPhone16,1", "runtime": "iOS-17-2"}, 
            {"name": "iPad Pro 12.9", "type": "iPad13,8", "runtime": "iOS-17-0"},
        ]
    
    async def list_available_runtimes(self) -> List[Dict]:
        """List available iOS runtimes"""
        try:
            result = subprocess.run(
                ['xcrun', 'simctl', 'list', 'runtimes', '--json'],
                capture_output=True, text=True, check=True
            )
            data = json.loads(result.stdout)
            return data.get('runtimes', [])
        except Exception as e:
            logger.error(f"Failed to list iOS runtimes: {e}")
            return []
    
    async def list_device_types(self) -> List[Dict]:
        """List available device types"""
        try:
            result = subprocess.run(
                ['xcrun', 'simctl', 'list', 'devicetypes', '--json'],
                capture_output=True, text=True, check=True
            )
            data = json.loads(result.stdout)
            return data.get('devicetypes', [])
        except Exception as e:
            logger.error(f"Failed to list device types: {e}")
            return []
    
    async def create_simulator(self, name: str, device_type: str, runtime: str) -> Optional[str]:
        """Create a new iOS simulator"""
        try:
            result = subprocess.run(
                ['xcrun', 'simctl', 'create', name, device_type, runtime],
                capture_output=True, text=True, check=True
            )
            udid = result.stdout.strip()
            logger.info(f"Created iOS simulator {name} with UDID: {udid}")
            return udid
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to create simulator {name}: {e.stderr}")
            return None
    
    async def boot_simulator(self, udid: str) -> bool:
        """Boot an iOS simulator"""
        try:
            # Check if already booted
            result = subprocess.run(
                ['xcrun', 'simctl', 'list', 'devices', '--json'],
                capture_output=True, text=True, check=True
            )
            data = json.loads(result.stdout)
            
            # Find the simulator
            for runtime, devices in data.get('devices', {}).items():
                for device in devices:
                    if device.get('udid') == udid:
                        if device.get('state') == 'Booted':
                            logger.info(f"Simulator {udid} already booted")
                            return True
                        break
            
            # Boot the simulator
            subprocess.run(
                ['xcrun', 'simctl', 'boot', udid],
                check=True, capture_output=True
            )
            
            # Wait for boot to complete
            await self._wait_for_boot(udid)
            logger.info(f"Successfully booted iOS simulator {udid}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to boot simulator {udid}: {e}")
            return False
    
    async def _wait_for_boot(self, udid: str, timeout: int = 120):
        """Wait for simulator to finish booting"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                result = subprocess.run(
                    ['xcrun', 'simctl', 'bootstatus', udid],
                    capture_output=True, text=True, check=True, timeout=10
                )
                if "Boot status: Booted" in result.stdout:
                    return True
            except:
                pass
            await asyncio.sleep(2)
        
        raise TimeoutError(f"Simulator {udid} failed to boot within {timeout} seconds")
    
    async def install_app(self, udid: str, app_path: str) -> bool:
        """Install app on iOS simulator"""
        try:
            subprocess.run(
                ['xcrun', 'simctl', 'install', udid, app_path],
                check=True, capture_output=True
            )
            logger.info(f"Installed app {app_path} on simulator {udid}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to install app on simulator {udid}: {e}")
            return False
    
    async def shutdown_simulator(self, udid: str) -> bool:
        """Shutdown iOS simulator"""
        try:
            subprocess.run(
                ['xcrun', 'simctl', 'shutdown', udid],
                check=True, capture_output=True
            )
            logger.info(f"Shutdown iOS simulator {udid}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to shutdown simulator {udid}: {e}")
            return False
    
    async def delete_simulator(self, udid: str) -> bool:
        """Delete iOS simulator"""
        try:
            subprocess.run(
                ['xcrun', 'simctl', 'delete', udid],
                check=True, capture_output=True
            )
            logger.info(f"Deleted iOS simulator {udid}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to delete simulator {udid}: {e}")
            return False

class AndroidEmulatorManager:
    """Manages Android emulators using Android SDK tools"""
    
    def __init__(self):
        self.emulators = {}
        self.sdk_path = self._find_android_sdk()
        self.avd_manager = os.path.join(self.sdk_path, 'cmdline-tools', 'latest', 'bin', 'avdmanager')
        self.emulator_cmd = os.path.join(self.sdk_path, 'emulator', 'emulator')
        
    def _find_android_sdk(self) -> str:
        """Find Android SDK path"""
        # Common Android SDK locations
        possible_paths = [
            os.path.expanduser('~/Library/Android/sdk'),  # macOS
            os.path.expanduser('~/Android/Sdk'),  # Linux
            os.path.expanduser('~/AppData/Local/Android/Sdk'),  # Windows
            os.environ.get('ANDROID_SDK_ROOT', ''),
            os.environ.get('ANDROID_HOME', ''),
        ]
        
        for path in possible_paths:
            if path and os.path.exists(path):
                return path
        
        raise RuntimeError("Android SDK not found. Please set ANDROID_SDK_ROOT or ANDROID_HOME")
    
    async def list_system_images(self) -> List[Dict]:
        """List available system images"""
        try:
            result = subprocess.run(
                [self.avd_manager, 'list', 'target'],
                capture_output=True, text=True, check=True
            )
            # Parse system images from output
            images = []
            for line in result.stdout.split('\n'):
                if 'system-images' in line:
                    images.append({'name': line.strip()})
            return images
        except Exception as e:
            logger.error(f"Failed to list system images: {e}")
            return []
    
    async def create_avd(self, name: str, system_image: str, device_type: str = "pixel") -> bool:
        """Create Android Virtual Device"""
        try:
            # Create AVD
            process = subprocess.Popen(
                [self.avd_manager, 'create', 'avd', '-n', name, '-k', system_image, '-d', device_type],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Answer prompts automatically
            stdout, stderr = process.communicate(input='\n\n')  # Accept defaults
            
            if process.returncode == 0:
                logger.info(f"Created Android AVD: {name}")
                return True
            else:
                logger.error(f"Failed to create AVD {name}: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"Error creating AVD {name}: {e}")
            return False
    
    async def start_emulator(self, avd_name: str, port: int = 5554) -> bool:
        """Start Android emulator"""
        try:
            # Start emulator in background
            cmd = [
                self.emulator_cmd,
                '-avd', avd_name,
                '-port', str(port),
                '-no-audio',
                '-no-window',  # Headless mode for CI
                '-gpu', 'swiftshader_indirect',
                '-no-snapshot-save',
                '-no-snapshot-load',
                '-camera-back', 'none',
                '-camera-front', 'none'
            ]
            
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            # Wait for emulator to start
            await self._wait_for_emulator(port)
            
            logger.info(f"Started Android emulator {avd_name} on port {port}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to start emulator {avd_name}: {e}")
            return False
    
    async def _wait_for_emulator(self, port: int, timeout: int = 300):
        """Wait for emulator to be ready"""
        adb_cmd = os.path.join(self.sdk_path, 'platform-tools', 'adb')
        device_id = f"emulator-{port}"
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                # Check if device is online
                result = subprocess.run(
                    [adb_cmd, '-s', device_id, 'shell', 'getprop', 'sys.boot_completed'],
                    capture_output=True, text=True, timeout=10
                )
                
                if result.returncode == 0 and '1' in result.stdout:
                    # Wait a bit more for full boot
                    await asyncio.sleep(10)
                    return True
                    
            except subprocess.TimeoutExpired:
                pass
            except Exception:
                pass
            
            await asyncio.sleep(5)
        
        raise TimeoutError(f"Emulator on port {port} failed to start within {timeout} seconds")
    
    async def install_apk(self, port: int, apk_path: str) -> bool:
        """Install APK on Android emulator"""
        try:
            adb_cmd = os.path.join(self.sdk_path, 'platform-tools', 'adb')
            device_id = f"emulator-{port}"
            
            subprocess.run(
                [adb_cmd, '-s', device_id, 'install', '-r', apk_path],
                check=True, capture_output=True
            )
            
            logger.info(f"Installed APK {apk_path} on emulator {device_id}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to install APK on emulator: {e}")
            return False
    
    async def stop_emulator(self, port: int) -> bool:
        """Stop Android emulator"""
        try:
            adb_cmd = os.path.join(self.sdk_path, 'platform-tools', 'adb')
            device_id = f"emulator-{port}"
            
            subprocess.run(
                [adb_cmd, '-s', device_id, 'emu', 'kill'],
                check=True, capture_output=True
            )
            
            logger.info(f"Stopped Android emulator on port {port}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to stop emulator on port {port}: {e}")
            return False

class DeviceTestManager:
    """Main device testing manager"""
    
    def __init__(self, config_file: str = "device_config.json"):
        self.config = self._load_config(config_file)
        self.ios_manager = iOSSimulatorManager()
        self.android_manager = AndroidEmulatorManager()
        self.active_devices = {}
        
    def _load_config(self, config_file: str) -> Dict:
        """Load device configuration"""
        default_config = {
            "ios_devices": [
                {
                    "name": "FWB-iPhone-15-Pro",
                    "device_type": "iPhone15,2",
                    "runtime": "iOS-17-0"
                },
                {
                    "name": "FWB-iPhone-16-Pro", 
                    "device_type": "iPhone16,1",
                    "runtime": "iOS-17-2"
                }
            ],
            "android_devices": [
                {
                    "name": "FWB-Pixel-8-Pro",
                    "system_image": "system-images;android-33;google_apis;x86_64",
                    "device_type": "pixel_8_pro",
                    "port": 5554
                },
                {
                    "name": "FWB-Galaxy-S24",
                    "system_image": "system-images;android-34;google_apis;x86_64", 
                    "device_type": "Galaxy S24",
                    "port": 5556
                }
            ],
            "test_settings": {
                "auto_create_devices": True,
                "cleanup_on_exit": True,
                "parallel_startup": True
            }
        }
        
        if os.path.exists(config_file):
            with open(config_file, 'r') as f:
                user_config = json.load(f)
                default_config.update(user_config)
        else:
            with open(config_file, 'w') as f:
                json.dump(default_config, f, indent=2)
        
        return default_config
    
    async def setup_all_devices(self) -> Dict[str, DeviceSpec]:
        """Setup all configured devices"""
        logger.info("Setting up test devices...")
        
        devices = {}
        tasks = []
        
        # Setup iOS devices
        for ios_config in self.config.get('ios_devices', []):
            task = asyncio.create_task(self._setup_ios_device(ios_config))
            tasks.append(('ios', ios_config['name'], task))
        
        # Setup Android devices
        for android_config in self.config.get('android_devices', []):
            task = asyncio.create_task(self._setup_android_device(android_config))
            tasks.append(('android', android_config['name'], task))
        
        # Wait for all devices to be ready
        for platform, name, task in tasks:
            try:
                device_spec = await task
                if device_spec:
                    devices[device_spec.id] = device_spec
                    logger.info(f"✅ {platform.upper()} device {name} ready")
                else:
                    logger.error(f"❌ Failed to setup {platform} device {name}")
            except Exception as e:
                logger.error(f"❌ Error setting up {platform} device {name}: {e}")
        
        self.active_devices = devices
        logger.info(f"Device setup complete. {len(devices)} devices ready for testing.")
        return devices
    
    async def _setup_ios_device(self, config: Dict) -> Optional[DeviceSpec]:
        """Setup single iOS device"""
        try:
            name = config['name']
            device_type = config['device_type']
            runtime = config['runtime']
            
            # Create simulator
            udid = await self.ios_manager.create_simulator(name, device_type, runtime)
            if not udid:
                return None
            
            # Boot simulator
            boot_success = await self.ios_manager.boot_simulator(udid)
            if not boot_success:
                return None
            
            device_spec = DeviceSpec(
                id=f"ios_{name}",
                name=name,
                platform="ios",
                version=runtime.replace('iOS-', '').replace('-', '.'),
                device_type=device_type,
                udid=udid,
                status="running"
            )
            
            return device_spec
            
        except Exception as e:
            logger.error(f"Error setting up iOS device {config.get('name', 'unknown')}: {e}")
            return None
    
    async def _setup_android_device(self, config: Dict) -> Optional[DeviceSpec]:
        """Setup single Android device"""
        try:
            name = config['name']
            system_image = config['system_image']
            device_type = config.get('device_type', 'pixel')
            port = config.get('port', 5554)
            
            # Create AVD
            avd_success = await self.android_manager.create_avd(name, system_image, device_type)
            if not avd_success:
                # AVD might already exist, continue
                pass
            
            # Start emulator
            start_success = await self.android_manager.start_emulator(name, port)
            if not start_success:
                return None
            
            device_spec = DeviceSpec(
                id=f"android_{name}",
                name=name,
                platform="android",
                version=system_image.split(';')[1].replace('android-', ''),
                device_type=device_type,
                port=port,
                status="running"
            )
            
            return device_spec
            
        except Exception as e:
            logger.error(f"Error setting up Android device {config.get('name', 'unknown')}: {e}")
            return None
    
    async def install_app_on_all_devices(self, ios_app_path: str, android_apk_path: str):
        """Install apps on all active devices"""
        logger.info("Installing apps on all devices...")
        
        tasks = []
        
        for device_id, device_spec in self.active_devices.items():
            if device_spec.platform == "ios" and ios_app_path:
                task = self.ios_manager.install_app(device_spec.udid, ios_app_path)
                tasks.append((device_id, task))
            elif device_spec.platform == "android" and android_apk_path:
                task = self.android_manager.install_apk(device_spec.port, android_apk_path)
                tasks.append((device_id, task))
        
        # Wait for all installations
        for device_id, task in tasks:
            try:
                success = await task
                if success:
                    logger.info(f"✅ App installed on {device_id}")
                else:
                    logger.error(f"❌ App installation failed on {device_id}")
            except Exception as e:
                logger.error(f"❌ Error installing app on {device_id}: {e}")
    
    async def cleanup_all_devices(self):
        """Cleanup all devices"""
        logger.info("Cleaning up test devices...")
        
        cleanup_tasks = []
        
        for device_id, device_spec in self.active_devices.items():
            if device_spec.platform == "ios":
                task = self.ios_manager.shutdown_simulator(device_spec.udid)
                cleanup_tasks.append(task)
            elif device_spec.platform == "android":
                task = self.android_manager.stop_emulator(device_spec.port)
                cleanup_tasks.append(task)
        
        # Wait for all cleanups
        await asyncio.gather(*cleanup_tasks, return_exceptions=True)
        
        self.active_devices.clear()
        logger.info("Device cleanup completed")
    
    def get_device_status(self) -> Dict:
        """Get status of all devices"""
        return {
            device_id: asdict(device_spec) 
            for device_id, device_spec in self.active_devices.items()
        }
    
    def save_device_report(self, output_file: str = "device_report.json"):
        """Save device status report"""
        report = {
            'timestamp': time.time(),
            'total_devices': len(self.active_devices),
            'ios_devices': len([d for d in self.active_devices.values() if d.platform == 'ios']),
            'android_devices': len([d for d in self.active_devices.values() if d.platform == 'android']),
            'devices': self.get_device_status()
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Device report saved to {output_file}")

# CLI Interface
async def main():
    """CLI interface for device management"""
    import argparse
    
    parser = argparse.ArgumentParser(description='FWB Device Testing Manager')
    parser.add_argument('--config', default='device_config.json', help='Device configuration file')
    parser.add_argument('--setup', action='store_true', help='Setup all devices')
    parser.add_argument('--cleanup', action='store_true', help='Cleanup all devices')
    parser.add_argument('--status', action='store_true', help='Show device status')
    parser.add_argument('--install-ios', help='iOS app path to install')
    parser.add_argument('--install-android', help='Android APK path to install')
    
    args = parser.parse_args()
    
    manager = DeviceTestManager(args.config)
    
    try:
        if args.setup:
            devices = await manager.setup_all_devices()
            print(f"✅ Setup complete. {len(devices)} devices ready.")
            
            if args.install_ios or args.install_android:
                await manager.install_app_on_all_devices(
                    args.install_ios, 
                    args.install_android
                )
            
            manager.save_device_report()
            
        elif args.cleanup:
            await manager.cleanup_all_devices()
            print("✅ Cleanup complete.")
            
        elif args.status:
            # Load existing devices if any
            status = manager.get_device_status()
            print(json.dumps(status, indent=2))
            
        else:
            print("Please specify an action: --setup, --cleanup, or --status")
            
    except KeyboardInterrupt:
        logger.info("Operation interrupted by user")
        await manager.cleanup_all_devices()
    except Exception as e:
        logger.error(f"Error: {e}")
        await manager.cleanup_all_devices()

if __name__ == "__main__":
    asyncio.run(main())
