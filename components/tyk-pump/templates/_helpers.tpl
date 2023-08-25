{{/*
Expand the name of the chart.
*/}}
{{- define "tyk-pump.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-pump.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-pump.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tyk-pump.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-pump.redis_secret_name" -}}
{{- if .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.name -}}
{{ .Values.global.redis.passSecret.name }}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-pump.redis_secret_key" -}}
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

{{- define "tyk-pump.mongo_url" -}}
{{- if .Values.global.mongo.mongoURL -}}
{{ .Values.global.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-pump.mongo_url_secret_name" -}}
{{- if .Values.global.mongo.connectionURLSecret -}}
{{- if .Values.global.mongo.connectionURLSecret.name -}}
{{ .Values.global.mongo.connectionURLSecret.name }}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-pump.mongo_url_secret_key" -}}
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

{{- define "tyk-pump.pg_connection_string" -}}
{{- if .Values.global.postgres -}}
{{- range $key, $value := .Values.global.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-pump.pg_connection_string_secret_name" -}}
{{- if .Values.global.postgres.connectionStringSecret -}}
{{- if .Values.global.postgres.connectionStringSecret.name -}}
{{ .Values.global.postgres.connectionStringSecret.name }}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-pump.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-pump.pg_connection_string_secret_key" -}}
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


{{- define "tyk-pump.uptimePump" -}}
{{- if .Values.pump.uptimePumpBackend -}}
{{ .Values.pump.uptimePumpBackend }}
{{- else -}}
disabled
{{- end -}}
{{- end -}}

{{- define "tyk-pump.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}