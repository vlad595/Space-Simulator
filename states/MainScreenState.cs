using System;
using System.Xml.Serialization;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

namespace SpaceSimulator.states
{
    public class MainScreenState : State
    {
        private Texture2D _pixel;
        private int _gridStep;
        public MainScreenState(Game1 game, GraphicsDevice graphicsDevice, ContentManager content) : base(game, graphicsDevice, content)
        {
            
        }

        public override void LoadContent()
        {
            _pixel = new Texture2D(_graphicsDevice, 1, 1);
            _pixel.SetData(new[] { Color.White });

            _gridStep = 25;
        }

        public override void Update(GameTime gameTime)
        {
            
        }

        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            spriteBatch.Begin();
            
            for (int i = 0; i < _graphicsDevice.Viewport.Width; i += _gridStep)
            {
                DrawLine(spriteBatch, new Vector2(i, 0), new Vector2(i, _graphicsDevice.Viewport.Height), Color.Gray);
            }

            for (int i = 0; i < _graphicsDevice.Viewport.Height; i += _gridStep)
            {
                DrawLine(spriteBatch, new Vector2(0, i), new Vector2(_graphicsDevice.Viewport.Width, i), Color.Gray);
            }

            spriteBatch.End();
        }

        public void DrawLine(SpriteBatch spriteBatch, Vector2 start, Vector2 end, Color color, float thickness = 1.0f)
        {

            float distance = Vector2.Distance(start, end);

            float angle = (float)Math.Atan2(end.Y - start.Y, end.X - start.X);

            spriteBatch.Draw(texture: _pixel, position: start, color: color, rotation: angle, origin: Vector2.Zero, scale: new Vector2(distance, thickness), layerDepth: 0f, effects: SpriteEffects.None, sourceRectangle: null);
        }
    }
}