# nixos-config

This is the NixOS Config Repo of Freifunk Rhein-Neckar.

The current deployment tool is [Colmena](https://github.com/zhaofengli/colmena).

Secrets are stored encypted with [agenix](https://github.com/ryantm/agenix) in the private
[nixos-secrets](https://github.com/Freifunk-Rhein-Neckar/nixos-secrets) Repository.

## Deployment

It's not neccesary to run NixOS to deploy. Hoewer the Nix package Mananger has
to be [installed](https://nixos.org/download/#download-nix-accordion).

Clone this repo with it's submodules and enter the dir.

Run `nix-shell`. This will give you an shell where all relevant packages (colmena,
agenix, niv, ... ) are installed.

#### Build only

```
colmena build
```

#### Build and deploy

```
colmena apply
```

You can also deploy to some to reduce impact:

```
colmena apply --on "gw01*"

colmena apply --on "gw0[1-4]*"

colmena apply --on "gw02,gw04,gw06,gw08"
```

And it's also possible to deploy in a way so config will only be activated for the next boot:

```
colmena apply boot

colmena apply --on "gw01" boot
```


## Secrets

To create, edit or view secrets `cd` into the secrets dir.

#### Create secrets

Modify `secrets.nix` with an editor of your choice and define which keys should be decryptable with which secret.

And now edit the secret:

#### Edit secrets

```
agenix -e gw01/fastd.age
```

#### Print secrets

```
agenix -d gw01/fastd.age
```

## Update

```
niv update nixpkgs
```

Ideally only commited and pushed changes are deployed.
