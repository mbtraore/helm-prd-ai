{{/*
Set the name of the Open WebUI resources
*/}}
{{- define "open-webui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Set the name of the integrated Ollama resources
*/}}
{{- define "ollama.name" -}}
open-webui-ollama
{{- end -}}

{{/*
Set the name of the integrated Pipelines resources
*/}}
{{- define "pipelines.name" -}}
open-webui-pipelines
{{- end -}}

{{/*
Constructs a semicolon-separated string of Ollama API endpoint URLs from the ollamaUrls list 
defined in the values.yaml file
*/}}
{{- define "ollamaUrls" -}}
{{- if .Values.ollamaUrls }}
{{- join ";" .Values.ollamaUrls | trimSuffix "/" }}
{{- end }}
{{- end }}

{{/*
Generates the URL for accessing the Ollama service within the Kubernetes cluster when the 
ollama.enabled value is set to true, which means that the Ollama Helm chart is being installed 
as a dependency of the Open WebUI chart
*/}}
{{- define "ollamaLocalUrl" -}}
{{- if .Values.ollama.enabled -}}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $ollamaServicePort := .Values.ollama.service.port | toString }}
{{- printf "http://%s.%s.svc.%s:%s" (default .Values.ollama.name .Values.ollama.fullnameOverride) (.Release.Namespace) $clusterDomain $ollamaServicePort }}
{{- end }}
{{- end }}

{{/*
Constructs a string containing the URLs of the Ollama API endpoints that the Open WebUI 
application should use based on which values are set for Ollama/ whether the Ollama
subchart is in use
*/}}
{{- define "ollamaBaseUrls" -}}
{{- $ollamaLocalUrl := include "ollamaLocalUrl" . }}
{{- $ollamaUrls := include "ollamaUrls" . }}
{{- if and .Values.ollama.enabled .Values.ollamaUrls }}
{{- printf "%s;%s" $ollamaUrls $ollamaLocalUrl }}
{{- else if .Values.ollama.enabled }}
{{- printf "%s" $ollamaLocalUrl }}
{{- else if .Values.ollamaUrls }}
{{- printf "%s" $ollamaUrls }}
{{- end }}
{{- end }}

{{/*
Create the chart name and version for the chart label
*/}}
{{- define "chart.name" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the base labels to include on chart resources
*/}}
{{- define "base.labels" -}}
helm.sh/chart: {{ include "chart.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create selector labels to include on all resources
*/}}
{{- define "base.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create selector labels to include on all Open WebUI resources
*/}}
{{- define "open-webui.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ .Chart.Name }}
{{- end }}

{{/*
Create labels to include on chart all Open WebUI resources
*/}}
{{- define "open-webui.labels" -}}
{{ include "base.labels" . }}
{{ include "open-webui.selectorLabels" . }}
{{- end }}

{{/*
Create selector labels to include on chart all Ollama resources
*/}}
{{- define "ollama.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "ollama.name" . }}
{{- end }}

{{/*
Create labels to include on chart all Ollama resources
*/}}
{{- define "ollama.labels" -}}
{{ include "base.labels" . }}
{{ include "ollama.selectorLabels" . }}
{{- end }}

{{/*
Create selector labels to include on chart all Pipelines resources
*/}}
{{- define "pipelines.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ .Values.nameOverride | default (include "pipelines.name" .)}}
{{- end }}

{{/*
Create labels to include on chart all Pipelines resources
*/}}
{{- define "pipelines.labels" -}}
{{ include "base.labels" . }}
{{ include "pipelines.selectorLabels" . }}
{{- end }}

{{/*
Create the service endpoint to use for Pipelines if the subchart is used
*/}}
{{- define "pipelines.serviceEndpoint" -}}
{{- if .Values.pipelines.enabled -}}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $pipelinesServicePort := .Values.pipelines.service.port | toString }}
{{- printf "http://%s.%s.svc.%s:%s" .Values.nameOverride | default (include "pipelines.name" .) (.Release.Namespace) $clusterDomain $pipelinesServicePort }}
{{- end }}
{{- end }}