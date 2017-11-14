new_wallpaper=$(find "$HOME/.wallpaper/" | shuf | head -n 1)
echo $new_wallpaper
/bin/bash -c "/usr/bin/feh --bg-max $new_wallpaper --no-fehbg" || true

# handle being called from systemd service
#copied from https://www.codegists.com/code/systemd-suspend-lock-screen/
# if [ -z "$XDG_RUNTIME_DIR" ] && [ -z "$SWAYSOCK"]; then
if [ -z "$SWAYSOCK"]; then
  # uid=$(id -u $USER)
  # export XDG_RUNTIME_DIR="/run/user/"$uid"/"
  export SWAYSOCK=$(find $XDG_RUNTIME_DIR -iname sway*sock)
fi

swaymsg output LVDS-1 bg "$new_wallpaper" fit || true

