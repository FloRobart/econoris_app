/// A simple command wrapper for deferring an action.
class Command {
  final Future<void> Function() run;
  const Command(this.run);
}
