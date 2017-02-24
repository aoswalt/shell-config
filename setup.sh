#! /bin/bash

# get script's dir
pushd $(dirname $0) > /dev/null
this_dir=$(pwd -P)
popd > /dev/null

home_dir=$(echo $HOME)

# simple files
files=(".bashrc" ".zshrc" ".tmux.conf" ".eslintrc.json" ".Xresources")
num_files=${#files[@]}

for (( index=0; index<${num_files}; ++index )); do
  ln -s $this_dir/${files[$index]} $home_dir/${files[$index]}
done

# aliases is a nested file
ln -s "${this_dir}/aliases.zsh" "${home_dir}/.oh-my-zsh/custom/aliases.zsh"

# need to ensure nvim foder exists first
nvim_dir=$home_dir/.config/nvim
if [ ! -d "${nvim_dir}" ]; then
  mkdir -p "${nvim_dir}"
fi
ln -s "${this_dir}/init.vim" "${nvim_dir}/init.vim"

konsole_profile_dir=$home_dir/.local/share/konsole
mkdir -p $konsole_profile_dir
ln -s "${this_dir}/konsole/Mine.profile" "${konsole_profile_dir}/Mine.profile"
ln -s "${this_dir}/konsole/Mine.colorscheme" "${konsole_profile_dir}/Mine.colorscheme"
