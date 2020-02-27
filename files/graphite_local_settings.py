SECRET_KEY = "1D33B3ED8392D3325383D39E28F14"

LOG_RENDERING_PERFORMANCE = True
LOG_CACHE_PERFORMANCE = True
LOG_METRIC_ACCESS = True

# MEMCACHE_HOSTS = ['10.10.10.10:11211', '10.10.10.11:11211', '10.10.10.12:11211']
# DEFAULT_CACHE_DURATION = 60 # Cache images and data for 1 minute

GRAPHITE_ROOT = "/usr/share/graphite"
CONF_DIR = "/etc/graphite-web"
STORAGE_DIR = "/var/lib/graphite-web"
CONTENT_DIR = "/usr/share/graphite/webapp/content"

DASHBOARD_CONF = "/etc/graphite-web/dashboard.conf"
GRAPHTEMPLATES_CONF = "/etc/graphite-web/graphTemplates.conf"

WHISPER_DIR = "/var/lib/carbon/whisper"
RRD_DIR = "/var/lib/carbon/rrd"
DATA_DIRS = [WHISPER_DIR, RRD_DIR]  # Default: set from the above variables
LOG_DIR = "/var/log/graphite-web/"
INDEX_FILE = "/var/lib/graphite-web/index"
