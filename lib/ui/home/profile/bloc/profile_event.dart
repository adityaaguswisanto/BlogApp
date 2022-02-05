abstract class ProfileEvent{}

class ProfileGetting extends ProfileEvent{}

class ProfileSubmitted extends ProfileEvent{
  final String? name;
  final String? image;

  ProfileSubmitted(this.name, this.image);
}