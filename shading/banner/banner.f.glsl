#version 330 core

out vec4 fColor;

in vec2 texCoord;

uniform sampler2D banner;

void main() {
  fColor = texture(banner, texCoord);
}
