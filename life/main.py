"""
Game of life shader edition
"""
import math
import random

from kivy.app import App
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.uix.widget import Widget
from kivy.resources import resource_find
from kivy.graphics.transformation import Matrix
from kivy.graphics.opengl import *
from kivy.graphics import *

WINDOW_SIZE = 512, 512
FBO_SIZE = 256, 256
FPS = 20

class Renderer(Widget):
    def __init__(self, **kwargs):
        # self.canvas = RenderContext(with_depth=False)
        super(Renderer, self).__init__(**kwargs)
        self.shader_path = resource_find('life_colors.glsl')
        # self.shader_path = resource_find('life.glsl')
        self.time = 0
        self.frame = 0

        # Reusable fullscreen quad for custom shader
        self.quad = Mesh(
            vertices=[
                -1.0, 1.0,
                -1.0, -1.0,
                1.0, 1.0,
                1.0, -1.0
            ],
            indices=[0, 1, 2, 1, 3, 2],
            fmt=[(b'v_pos', 2, 'float')],
            mode='triangles',
        )

        self.populate_fbo_1()
        self.fbo1.add_reload_observer(self.populate_fbo_1)
        self.populate_fbo_2()
        self.fbo2.add_reload_observer(self.populate_fbo_2)
        self.generate_initial_data(self.fbo1)

        # Instruction groups for odd and even frames
        self.fbo1.add(BindTexture(texture=self.fbo2.texture, index=1))
        self.fbo1.add(self.quad)

        self.fbo2.add(BindTexture(texture=self.fbo1.texture, index=1))
        self.fbo2.add(self.quad)

        # Render to fbo2 in the first frame
        self.fbo = self.fbo2

        # Widget instructions
        self.group1 = InstructionGroup()
        self.group1.add(Rectangle(size=WINDOW_SIZE, texture=self.fbo2.texture))

        self.group2 = InstructionGroup()
        self.group2.add(Rectangle(size=WINDOW_SIZE, texture=self.fbo1.texture))

        # Draw group1 in the first frame
        self.canvas.add(self.group1)

        Clock.schedule_interval(self._update, 1 / FPS)

    def _update(self, delta):
        # Window.screenshot(name='screenshots/screenshot{}.png'.format(str(self.frame).zfill(4)))

        self.time += delta
        self.frame += 1

        # Apparently I have to set a new uniform value for things to render
        # The uniform doesn't exist, but I guess that doesn't matter to the subsystem
        self.fbo['time'] = self.time
        self.fbo.draw()

        # Swap what fbo is rendered to the widget canvas
        self.canvas.remove(self.group1)
        self.canvas.add(self.group2)

        # Update the main canvas
        self.canvas.ask_update()

        # Swap around stuff for next frame
        self.group1, self.group2 = self.group2, self.group1
        self.fbo = self.fbo2 if self.fbo == self.fbo1 else self.fbo1

    def generate_initial_data(self, fbo):
        """Generates the start positions of the game"""
        choices = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 64, 128, 192, 255]
        size = FBO_SIZE[0] * FBO_SIZE[1] * 3
        buf = [random.choice(choices) for x in range(size)]
        buf = bytearray(buf)
        # fbo.texture.blit_buffer(buf, colorfmt='luminance', bufferfmt='ubyte')
        fbo.texture.blit_buffer(buf, colorfmt='rgb', bufferfmt='ubyte')

    def populate_fbo_1(self):
        self.fbo1 = self.create_fbo(FBO_SIZE)

    def populate_fbo_2(self):
        self.fbo2 = self.create_fbo(FBO_SIZE)

    def create_fbo(self, size):
        fbo = Fbo(size=size)
        fbo.shader.source = self.shader_path
        fbo.texture.mag_filter = 'nearest'
        fbo.texture.min_filter = 'nearest'
        fbo.texture.wrap = 'repeat'
        fbo['texture1'] = 1
        fbo['canvas_size'] = size
        return fbo

class RendererApp(App):
    def build(self):
        return Renderer()


if __name__ == "__main__":
    Window.size = WINDOW_SIZE
    RendererApp().run()
