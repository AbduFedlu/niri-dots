#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import subprocess
import threading
import json

class PowerProfileWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Power Profile Switcher")
        self.set_default_size(350, 200)
        self.set_border_width(10)
        
        # Profile data
        self.profiles = []
        self.profile_buttons = {}
        
        # Create main layout
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(main_box)
        
        # Title
        title_label = Gtk.Label()
        title_label.set_markup("<b>Power Profiles</b>")
        main_box.pack_start(title_label, False, False, 0)
        
        # Profile buttons
        self.button_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        main_box.pack_start(self.button_box, True, True, 0)
        
        # Status label
        self.status_label = Gtk.Label(label="Loading profiles...")
        self.status_label.get_style_context().add_class(Gtk.STYLE_CLASS_DIM_LABEL)
        main_box.pack_start(self.status_label, False, False, 0)
        
        # Load profiles
        self.load_profiles()
    
    def load_profiles(self):
        """Load available profiles from power-daemon-mgr"""
        try:
            result = subprocess.run(['power-daemon-mgr', 'list-profiles'], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                # Parse JSON output
                self.profiles = json.loads(result.stdout.strip())
            else:
                self.profiles = ["Balanced", "Performance", "Powersave"]
        except Exception as e:
            print(f"Error loading profiles: {e}")
            self.profiles = ["Balanced", "Performance", "Powersave"]
        
        self.create_profile_buttons()
    
    def create_profile_buttons(self):
        """Create buttons for each profile"""
        # Clear existing buttons
        for child in self.button_box.get_children():
            self.button_box.remove(child)
        
        self.profile_buttons = {}
        
        for profile in self.profiles:
            # Create button
            button = Gtk.Button(label=profile)
            button.set_margin_bottom(5)
            
            # Add icon based on profile type
            if "Performance" in profile:
                icon = Gtk.Image.new_from_icon_name("speedometer-symbolic", Gtk.IconSize.BUTTON)
                button.set_image(icon)
                button.set_always_show_image(True)
                button.get_style_context().add_class("suggested-action")
            elif "Powersave" in profile:
                icon = Gtk.Image.new_from_icon_name("battery-level-100-symbolic", Gtk.IconSize.BUTTON)
                button.set_image(icon)
                button.set_always_show_image(True)
                button.get_style_context().add_class("destructive-action")
            else:
                icon = Gtk.Image.new_from_icon_name("balance-scale-symbolic", Gtk.IconSize.BUTTON)
                button.set_image(icon)
                button.set_always_show_image(True)
            
            button.connect("clicked", self.on_profile_clicked, profile)
            
            self.button_box.pack_start(button, True, True, 0)
            self.profile_buttons[profile] = button
        
        self.status_label.set_text("Select a profile")
        self.show_all()
    
    def on_profile_clicked(self, button, profile):
        """Handle profile button click"""
        self.status_label.set_text(f"Switching to {profile}...")
        
        # Disable all buttons during operation
        for btn in self.profile_buttons.values():
            btn.set_sensitive(False)
        
        # Run in thread to avoid blocking UI
        def set_profile_thread():
            try:
                result = subprocess.run(['power-daemon-mgr', 'set-profile-override', profile], 
                                      capture_output=True, text=True, timeout=10)
                success = result.returncode == 0
            except Exception as e:
                print(f"Error setting profile: {e}")
                success = False
            
            GLib.idle_add(lambda: self.on_profile_set(success, profile))
        
        thread = threading.Thread(target=set_profile_thread)
        thread.daemon = True
        thread.start()
    
    def on_profile_set(self, success, profile):
        """Handle profile setting result"""
        if success:
            self.status_label.set_text(f"Active: {profile}")
            # Close window after successful profile change
            GLib.timeout_add(1000, self.close)  # Wait 1 second then close
        else:
            self.status_label.set_text(f"Failed to set {profile}")
            # Re-enable all buttons if failed
            for btn in self.profile_buttons.values():
                btn.set_sensitive(True)

def main():
    win = PowerProfileWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show()
    Gtk.main()

if __name__ == "__main__":
    main()