{{- /*
Expand the name of the chart.
*/}}
{{- define "tyk-dashboard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
ok
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-dashboard.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-dashboard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tyk-dashboard.gwproto" -}}
{{- if .Values.global.tls.gateway -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_proto" -}}
{{- if .Values.global.tls.dashboard -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.dash_url" -}}
{{ include "tyk-dashboard.dash_proto" . }}://dashboard-svc-{{.Release.Name}}-tyk-dashboard.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.dashboard }}
{{- end -}}

{{- define "tyk-dashboard.gateway_host" -}}
gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc
{{- end -}}

{{- define "tyk-dashboard.gateway_url" -}}
{{ include "tyk-dashboard.gwproto" . }}://gateway-svc-{{.Release.Name}}-tyk-gateway.{{ .Release.Namespace }}.svc:{{ .Values.global.servicePorts.gateway }}
{{- end -}}

{{- define "tyk-dashboard.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc:6379
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.redis_secret_name" -}}
{{- if .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.name -}}
{{ .Values.global.redis.passSecret.name }}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.redis_secret_key" -}}
{{- if .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.keyName -}}
{{ .Values.global.redis.passSecret.keyName }}
{{- else -}}
redisPass
{{- end -}}
{{- else -}}
redisPass
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.mongo_url" -}}
{{- if .Values.global.mongo.mongoURL -}}
{{ .Values.global.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.mongo_url_secret_name" -}}
{{- if .Values.global.mongo.connectionURLSecret -}}
{{- if .Values.global.mongo.connectionURLSecret.name -}}
{{ .Values.global.mongo.connectionURLSecret.name }}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.mongo_url_secret_key" -}}
{{- if .Values.global.mongo.connectionURLSecret -}}
{{- if .Values.global.mongo.connectionURLSecret.keyName -}}
{{ .Values.global.mongo.connectionURLSecret.keyName }}
{{- else -}}
mongoURL
{{- end -}}
{{- else -}}
mongoURL
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.pg_connection_string" -}}
{{- if .Values.global.postgres -}}
{{- range $key, $value := .Values.global.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.pg_connection_string_secret_name" -}}
{{- if .Values.global.postgres.connectionStringSecret -}}
{{- if .Values.global.postgres.connectionStringSecret.name -}}
{{ .Values.global.postgres.connectionStringSecret.name }}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-dashboard.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.pg_connection_string_secret_key" -}}
{{- if .Values.global.postgres.connectionStringSecret -}}
{{- if .Values.global.postgres.connectionStringSecret.keyName -}}
{{ .Values.global.postgres.connectionStringSecret.keyName }}
{{- else -}}
pgConnectionString
{{- end -}}
{{- else -}}
pgConnectionString
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.storageType" -}}
{{- if .Values.global.storageType -}}
{{- if eq "postgres" .Values.global.storageType -}}
postgres
{{- else if eq "mongo" .Values.global.storageType -}}
mongo
{{- end -}}
{{- else -}}
mongo
{{- end -}}
{{- end -}}

{{- define "tyk-dashboard.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}