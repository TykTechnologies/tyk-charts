# Changelog

## [Unreleased](https://github.com/TykTechnologies/tyk-charts/tree/HEAD)

**Added**
- Added support of prometheus pump
- Enabled TLS certificate configuration via secret 

## [v1.0.0-rc1](https://github.com/TykTechnologies/tyk-charts/tree/v1.0.0-rc1)

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