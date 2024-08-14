extension ObjectExtension<T extends Object?> on T {
  R cast<R>() {
    return this as R;
  }
}