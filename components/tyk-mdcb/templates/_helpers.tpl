{{/*
Expand the name of the chart.
*/}}
{{- define "tyk-mdcb.name" -}}
{{- default .Chart.Name .Values.mdcb.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tyk-mdcb.fullname" -}}
{{- if .Values.mdcb.fullnameOverride }}
{{- .Values.mdcb.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.mdcb.nameOverride }}
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
{{- define "tyk-mdcb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tyk-mdcb.labels" -}}
app: mdcb-{{ include "tyk-mdcb.fullname" . }}
helm.sh/chart: {{ include "tyk-mdcb.chart" . }}
{{ include "tyk-mdcb.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tyk-mdcb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tyk-mdcb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tyk-mdcb.serviceAccountName" -}}
{{- if .Values.mdcb.serviceAccount.enabled }}
{{- default (include "tyk-mdcb.fullname" .) .Values.mdcb.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.mdcb.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "mdcb.redis_url" -}}
{{- if .Values.global.redis.addrs -}}
{{ join "," .Values.global.redis.addrs }}
{{- else -}}
redis.{{ .Release.Namespace }}.svc:6379
{{- end -}}
{{- end -}}

{{- define "mdcb.redis_secret_name" -}}
{{- if ((.Values.global.redis.passSecret).name) -}}
{{ .Values.global.redis.passSecret.name }}
{{- else -}}
secrets-{{ include "tyk-mdcb.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "mdcb.redis_secret_key" -}}
{{- if ((.Values.global.redis.passSecret).keyName) -}}
{{ .Values.global.redis.passSecret.keyName }}
{{- else -}}
redisPass
{{- end -}}
{{- end -}}

{{- define "mdcb.storageType" -}}
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

{{- define "mdcb.pg_connection_string" -}}
{{- if .Values.global.postgres -}}
{{- range $key, $value := .Values.global.postgres }}{{ print $key "=" $value " " }}{{- end }}
{{- end -}}
{{- end -}}

{{- define "mdcb.pg_connection_string_secret_name" -}}
{{- if ((.Values.global.postgres.connectionStringSecret).name) -}}
{{ .Values.global.postgres.connectionStringSecret.name }}
{{- else -}}
secrets-{{ include "tyk-mdcb.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "mdcb.pg_connection_string_secret_key" -}}
{{- if ((.Values.global.postgres.connectionStringSecret).keyName) -}}
{{ .Values.global.postgres.connectionStringSecret.keyName }}
{{- else -}}
pgConnectionString
{{- end -}}
{{- end -}}

{{- define "mdcb.mongo_url" -}}
{{- if .Values.global.mongo.mongoURL -}}
{{ .Values.global.mongo.mongoURL }}
{{- else -}}
mongodb://mongo.{{ .Release.Namespace }}.svc:27017/tyk_analytics
{{- end -}}
{{- end -}}

{{- define "mdcb.mongo_url_secret_name" -}}
{{- if ((.Values.global.mongo.connectionURLSecret).name) -}}
{{ .Values.global.mongo.connectionURLSecret.name }}
{{- else -}}
secrets-{{ include "tyk-mdcb.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "mdcb.mongo_url_secret_key" -}}
{{- if ((.Values.global.mongo.connectionURLSecret).keyName) -}}
{{ .Values.global.mongo.connectionURLSecret.keyName }}
{{- else -}}
mongoURL
{{- end -}}
{{- end -}}

{{/*
HTTP Protocol that is used by Tyk MDCB. At the moment, TLS is not supported.
*/}}
{{- define "mdcb.proto" -}}
http
{{- end -}}

{{/*
HTTP Protocol that is used by Tyk MDCB. At the moment, TLS is not supported.
*/}}
{{- define "mdcb.svcPort" -}}
{{ .Values.mdcb.service.port }}
{{- end -}}

{{- define "mdcb.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
HealthCheckPort will take precedence to avoid breaking change
*/}}
{{- define "mdcb.healthCheckPort" }}
{{- if .Values.mdcb.probes.healthCheckPort -}}
{{ .Values.mdcb.probes.healthCheckPort }}
{{- else -}}
{{ .Values.mdcb.httpPort }}
{{- end }}
{{- end -}}
