# Changelog

## [Unreleased](https://github.com/TykTechnologies/tyk-charts/tree/HEAD)
[Full Changelog](https://github.com/TykTechnologies/tyk-charts/compare/v1.0.0...HEAD)

## [v1.0.0](https://github.com/TykTechnologies/tyk-charts/tree/v1.0.0)
[Full Changelog](https://github.com/TykTechnologies/tyk-charts/compare/v1.0.0-rc3...v1.0.0)

**Added:**
- Added support of hybrid-pump

## [v1.0.0-rc3](https://github.com/TykTechnologies/tyk-charts/tree/v1.0.0-rc3) 
[Full Changelog](https://github.com/TykTechnologies/tyk-charts/compare/v1.0.0-rc2...v1.0.0-rc3)

**Added:**
- New `tyk-mdcb-data-plane` chart.
- Enable setting multiple backends for Tyk Pump.
- Add new fields to values.yaml files to allow defining extra `volume` and `volumeMounts`.

**Updated:**
- Moved all subcharts to `/components` folder.
- Updated Tyk Pump backend configuration. So that multiple backends can be set.

## [v1.0.0-rc2](https://github.com/TykTechnologies/tyk-charts/tree/v1.0.0-rc2) 
[Full Changelog](https://github.com/TykTechnologies/tyk-charts/compare/v1.0.0-rc1...v1.0.0-rc2)

**Added**
- Added support of prometheus pump
- Enabled TLS certificate configuration via secret 

## [v1.0.0-rc1](https://github.com/TykTechnologies/tyk-charts/tree/v1.0.0-rc1)
[Full Changelog](https://github.com/TykTechnologies/tyk-charts/compare/4fd006efe39daa60b6808986d569fcb525cae808...v1.0.0-rc1)

**Added**
- Added pump component chart
- Added gateway component chart
- Added umbrella chart for Tyk Open Source

**Updated**
- Remove config files and set default configuration using environment variables
- Create postgres pump by default
- Change default image tags of pump(v1.6.0) and gateway(v4.0.9)
- Set `TYK_GW_POLICIES_ALLOWEXPLICITPOLICYID` to true
- Change default image tags of pump(v1.7.0) and gateway(v4.3.1)
