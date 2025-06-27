name: Generate Output Files

jobs:
  generate-files:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate output files
        run: |
          mkdir -p outputs

          # Version info
          echo "Version: ${{ github.ref_name }}" > outputs/version.txt
          echo "Build: ${{ github.run_number }}" >> outputs/version.txt
          echo "Date: $(date)" >> outputs/version.txt

          # JSON format
          cat > outputs/build-info.json << EOF
          {
            "version": "${{ github.ref_name }}",
            "build_number": "${{ github.run_number }}",
            "commit": "${{ github.sha }}",
            "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
          }
          EOF

          # Environment file
          cat > outputs/.env << EOF
          VERSION=${{ github.ref_name }}
          BUILD_NUMBER=${{ github.run_number }}
          COMMIT_SHA=${{ github.sha }}
          EOF

      - name: Upload all output files
        uses: actions/upload-artifact@v4
        with:
          name: build-outputs
          path: outputs/
