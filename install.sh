#!/bin/bash
set -e

bash credentials_setup.sh
bash copy_scripts.sh
bash create_wrappers.sh
bash setup_services.sh

echo "✅ Setup complete!"
echo "🔄 Running initial login..."
/usr/local/bin/wifi-login
