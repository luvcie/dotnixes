My NixOS configuration. 


```
                         .       .
                        / `.   .' \
                .---.  <    > <    >  .---.
                |    \  \ - ~ ~ - /  /    |
                 ~-..-~             ~-..-~
             \~~~\.'                    `./~~~/
   .-~~^-.    \__/                        \__/
 .'  O    \     /               /       \  \
(_____,    `._.'               |         }  \/~~~/
 `----.          /       }     |        /    \__/
       `-.      |       /      |       /      `. ,~~|
           ~-.__|      /_ - ~ ^|      /- _      `..-'   f: f:
                |     /        |     /     ~-.     `-. _||_||_
                |_____|        |_____|         ~ - . _ _ _ _ _>

```

Cheatsheet of useful NixOS and git commands:

sudo nix-collect-garbage -d

nix-collect-garbage -d

nix flake update

sudo nixos-rebuild switch --flake .

home-manager switch --flake .

home-manager news --flake .

git commit --amend

git reset --hard #Returns all files to how they were at HEAD, the latest commit

git stash #Stashes local changes so you can return to this state
