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
{{- /* Adds support for older charts with the host and port options */}}
{{- else if and .Values.global.redis.host .Values.global.redis.port -}}
{{ .Values.global.redis.host }}:{{ .Values.global.redis.port }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-pump.mongo_url" -}}
{{- if .Values.mongo.mongoURL -}}
{{ .Values.mongo.mongoURL }}
{{- /* Adds support for older charts with the host and port options */}}
{{- else if and .Values.mongo.host .Values.mongo.port -}}
mongodb://{{ .Values.mongo.host }}:{{ .Values.mongo.port }}/tyk_analytics
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc.cluster.local:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "tyk-pump.pg_connection_string" -}}
{{- if .Values.postgres -}}
{{- range $key, $value := .Values.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "tyk-pump.uptimePump" -}}
{{- if .Values.pump.uptimePumpBackend -}}
{{ .Values.pump.uptimePumpBackend }}
{{- else -}}
disabled
{{- end -}}
{{- end -}}
