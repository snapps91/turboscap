#!/bin/bash

PROFILE="xccdf_org.ssgproject.content_profile_cis"
SCAP_FILE="/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml"
RESULT_XML="./open-scap-result.xml"
REPORT_HTML="./open-scap-report.html"
FIX_SCRIPT="./fix-script.sh"

run_scan() {
    echo "Running OpenSCAP Scan..."
    oscap xccdf eval \
        --profile "$PROFILE" \
        --results "$RESULT_XML" \
        --report "$REPORT_HTML" \
        "$SCAP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Scan completed successfully. Report available: $REPORT_HTML"
    else
        echo "OpenSCAP scan failed."
    fi
}

generate_fix() {
    echo "Generating Fix Script..."
    oscap xccdf generate fix \
        --profile "$PROFILE" \
        --output "$FIX_SCRIPT" \
        "$SCAP_FILE"
    
    if [ $? -eq 0 ]; then
        chmod +x "$FIX_SCRIPT"
        echo "Fix script generated: $FIX_SCRIPT"
    else
        echo "Fix script generation failed."
    fi
}

apply_fix() {
    if [ ! -f "$FIX_SCRIPT" ]; then
        echo "Error: Fix script not found. Generate it first with './openscap_cli.sh fix'"
        exit 1
    fi

    echo "WARNING: You are about to apply security fixes!"
    read -p "Do you want to proceed? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
        echo "Applying security fixes..."
        bash "$FIX_SCRIPT"
        echo "Fix applied successfully!"
    else
        echo "Operation canceled."
    fi
}

case "$1" in
    scan)
        run_scan
        ;;
    fix)
        generate_fix
        ;;
    apply-fix)
        apply_fix
        ;;
    *)
        echo "Usage: $0 {scan|fix|apply-fix}"
        echo "  scan       - Run OpenSCAP scan and generate the report"
        echo "  fix        - Generate the remediation script"
        echo "  apply-fix  - Apply the generated fix script"
        exit 1
        ;;
esac
