# Adminer (services)

Options for configuring adminer in the services category.

## enable
**Location:** perSystem.snow-blower.services.adminer.enable

Whether to enable Adminer  service.

**Type:**

`boolean`

**Default:**
```nix
false
```

**Example:**

```nix
true
```

**Declared by:**

- [services/adminer, via option flake.flakeModules.services](modules/services/adminer)


## package
**Location:** perSystem.snow-blower.services.adminer.package

The package Adminer should use.

**Type:**

`package`

**Default:**
```nix
<derivation adminer-5.1.0>
```

**Declared by:**

- [services/adminer, via option flake.flakeModules.services](modules/services/adminer)


## settings.host
**Location:** perSystem.snow-blower.services.adminer.settings.host

The host Adminer will listen on

**Type:**

`string`

**Default:**
```nix
"127.0.0.1"
```

**Declared by:**

- [services/adminer, via option flake.flakeModules.services](modules/services/adminer)


## settings.port
**Location:** perSystem.snow-blower.services.adminer.settings.port

The port Adminer will listen on

**Type:**

`signed integer or string`

**Default:**
```nix
8080
```

**Declared by:**

- [services/adminer, via option flake.flakeModules.services](modules/services/adminer)

