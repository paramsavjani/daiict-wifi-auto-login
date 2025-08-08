#!/bin/bash
set -e

./credentials_setup.sh
./copy_scripts.sh
./create_wrappers.sh
./setup_services.sh

echo "✅ Setup complete!"
echo "🔄 Please restart your system and ensure 'DA_Public' is set to auto-connect."