{{/*
Expand the name of the chart.
*/}}
{{- define "tyk-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-gateway.fullname" -}}
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

{{- define "tyk-gateway.gwproto" -}}
{{- if .Values.global.tls.gateway -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "tyk-gateway.dash_proto" -}}
{{- if .Values.global.tls.dashboard -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tyk-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* Create Semantic Version of gateway without prefix v */}}
{{- define "tyk-gateway.gateway-version" -}}
{{- printf "%s" .Values.gateway.image.tag | replace "v" "" -}}
{{- end -}}

{{- define "tyk-gateway.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- /* Adds support for older charts with the host and port options */}}
{{- else if and .Values.global.redis.host .Values.global.redis.port -}}
{{ .Values.global.redis.host }}:{{ .Values.global.redis.port }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end -}}
{{- end -}}

{{- define "tyk-gateway.redis_secret_name" -}}
{{- if .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.name -}}
{{ .Values.global.redis.passSecret.name }}
{{- else -}}
secrets-{{ include "tyk-gateway.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-gateway.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-gateway.redis_secret_key" -}}
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

{{- define "tyk-gateway.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}