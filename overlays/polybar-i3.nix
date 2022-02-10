(self: super: {
  polybar = super.polybar.override {
    pulseSupport = true;
    i3Support = true;
  };
})