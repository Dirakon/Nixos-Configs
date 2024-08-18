#!/usr/bin/env fish
cd ..


for i in secrets/*.yaml 
	sops updatekeys "$i"
end

cd secrets/
