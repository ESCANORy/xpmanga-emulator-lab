# XPManga emulator lab

Manual QA helper: `workflow_dispatch` boots a KVM-accelerated Android emulator on a GitHub-hosted runner and exposes
its adb port to the operator through an authenticated, single-port chisel reverse tunnel. It checks out no app code
and uses no repository secrets. Safe to delete when testing is finished.
