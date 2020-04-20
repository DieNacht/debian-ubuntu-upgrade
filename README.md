# debian-ubuntu-upgrade
> Inspired by inexistence: https://github.com/Aniverse/inexistence

> ALSO Inspired by quickbox-lite: https://github.com/amefs/quickbox-lite

> 警告：不保证本脚本能正常使用，翻车了不负责；上车前还请三思  
> 建议重装完系统后安装本脚本，非全新安装的情况下翻车几率比较高  
> 请使用root权限运行本脚本

## Interactive Mode

```
bash <(wget --no-check-certificate -qO- https://github.com/DieNacht/debian-ubuntu-upgrade/raw/master/upgrade.sh)
```

## Non-Interactive Upgrade Mode

```
bash <(wget --no-check-certificate -qO- https://github.com/DieNacht/debian-ubuntu-upgrade/raw/master/upgrade.sh) --version Version_Codename [--mirror Source_Loaction]
```

## Change Source Mode

```
bash <(wget --no-check-certificate -qO- https://github.com/DieNacht/debian-ubuntu-upgrade/raw/master/upgrade.sh) --mirror Source_Loaction
```

Mirror目前支持 `US / AU / CN / FR / DE / JP / RU / UK`

可升级的系统 `Ubuntu 14.04 / 16.04 / 18.04`、`Debian 7 / 8 / 9` 

