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

{{- define "tyk-gateway.gw_proto" -}}
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
redis.{{ .Release.Namespace }}.svc:6379
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

{{- define "tyk-gateway.redis_sentinel_secret_name" -}}
{{- if and .Values.global.redis.enableSentinel .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.name -}}
{{ .Values.global.redis.passSecret.name }}
{{- else -}}
secrets-{{ include "tyk-gateway.fullname" . }}
{{- end -}}
{{- else -}}
secrets-{{ include "tyk-gateway.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tyk-gateway.redis_sentinel_secret_key" -}}
{{- if and .Values.global.redis.enableSentinel .Values.global.redis.passSecret -}}
{{- if .Values.global.redis.passSecret.sentinelKeyName -}}
{{ .Values.global.redis.passSecret.sentinelKeyName }}
{{- else -}}
redisSentinelPass
{{- end -}}
{{- else -}}
redisSentinelPass
{{- end -}}
{{- end -}}

{{- define "tyk-gateway.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "otel-headers" -}}
{{- $headersList := list -}}

{{- range $key, $value := .Values.gateway.opentelemetry.headers -}}
    {{- if kindIs "string" $value -}}
        {{- $headersList = append $headersList (printf "%s:%s" $key $value) -}}
    {{- else if (and (kindIs "map" $value) (hasKey $value "fromSecret")) -}}
        {{- $secret := lookup "v1" "Secret" $.Release.Namespace $value.fromSecret.name -}}
        {{- if $secret -}}
            {{- $secretValue := index $secret.data $value.fromSecret.key | b64dec -}}
            {{- $headersList = append $headersList (printf "%s:%s" $key $secretValue) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- if $headersList -}}
    {{- join "," $headersList -}}
{{- end -}}
{{- end -}}

{{- define "otel-secretMountPath" -}}
    {{- if ((.Values.gateway.opentelemetry).tls).secretMountPath -}}
        {{ trimSuffix "/" .Values.gateway.opentelemetry.tls.secretMountPath }}
    {{- else -}}
        /etc/ssl/certs
    {{- end -}}
{{- end -}}

{{- define "otel-tlsCertPath" -}}
    {{- if .Values.gateway.opentelemetry.tls.certFileName -}}
        {{- if .Values.gateway.opentelemetry.tls.certificateSecretName -}}
        {{- printf "%s/%s" ( include "otel-secretMountPath" . ) .Values.gateway.opentelemetry.tls.certFileName -}}
        {{- else -}}
        {{ .Values.gateway.opentelemetry.tls.certFileName }}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "otel-tlsKeyPath"}}
    {{- if .Values.gateway.opentelemetry.tls.keyFileName -}}
        {{- if .Values.gateway.opentelemetry.tls.certificateSecretName -}}
        {{- printf "%s/%s" ( include "otel-secretMountPath" . ) .Values.gateway.opentelemetry.tls.keyFileName -}}
        {{- else -}}
        {{.Values.gateway.opentelemetry.tls.keyFileName}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "otel-tlsCAPath"}}
    {{- if .Values.gateway.opentelemetry.tls.caFileName -}}
        {{- if .Values.gateway.opentelemetry.tls.certificateSecretName -}}
        {{- printf "%s/%s" ( include "otel-secretMountPath" . ) .Values.gateway.opentelemetry.tls.caFileName -}}
        {{- else -}}
        {{.Values.gateway.opentelemetry.tls.caFileName -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
