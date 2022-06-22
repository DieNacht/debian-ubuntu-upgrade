# Debian/Ubuntu-OS Upgrade
> Inspired by inexistence: https://github.com/Aniverse/inexistence

> ALSO Inspired by quickbox-lite: https://github.com/amefs/quickbox-lite

> 警告：不保证本脚本能正常使用，翻车了不负责；上车前还请三思  
> 建议重装完系统后安装本脚本，非全新安装的情况下翻车几率比较高  
> 请使用root权限运行本脚本

## Interactive Mode

```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DieNacht/debian-ubuntu-upgrade/old-stable(trusty-to-focal)/upgrade.sh)
```

## Interactive Upgrade Mode Without Source Change

```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DieNacht/debian-ubuntu-upgrade/old-stable(trusty-to-focal)/upgrade.sh) --no-mirror-change
```

## Interactive Change Source Mode

```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DieNacht/debian-ubuntu-upgrade/old-stable(trusty-to-focal)/upgrade.sh) --only-mirror-change
```

## Non-Interactive Upgrade Mode

```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DieNacht/debian-ubuntu-upgrade/old-stable(trusty-to-focal)/upgrade.sh) --version Version_Codename [--mirror Source_Loaction]
```

## Non-Interactive Change Source Mode

```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/DieNacht/debian-ubuntu-upgrade/old-stable(trusty-to-focal)/upgrade.sh) --mirror Source_Loaction
```

### Mirror目前支持 `官方源 / 教育源 / 国内主机服务商源 / 盒子提供商源`

官方源包括 `US / AU / CN / FR / DE / JP / RU / UK`

教育源包括 `TUNA / USTC / MIT`

国内主机源包括 `Aliyun / Netease(163) / Huawei Cloud`

盒子源包括 `Online SAS(Only for Online SAS) / Hetzner(Only for Hetzner) / Leaseweb / OVH / Ikoula`

### 支持的系统版本 `Ubuntu 14.04 / 16.04 / 18.04 / 20.04`、`Debian 8 / 9 / 10 / 11` 

