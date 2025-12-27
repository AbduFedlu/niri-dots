if status is-interactive
    
	fastfetch

	starship init fish | source

        zoxide init fish | source
end

fish_add_path /home/abatu/.spicetify



# Force Wayland compositors (like Niri) to use the Intel iGPU render node
set -gx WLR_DRM_DEVICES /dev/dri/renderD129
