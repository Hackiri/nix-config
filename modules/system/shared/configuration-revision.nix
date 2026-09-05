# Record the source revision in built system generations when available.
{inputs, ...}: {
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
