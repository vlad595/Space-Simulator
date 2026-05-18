#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

sampler2D SpriteTextureSampler : register(s0);

float2 PlanetPos;     // Центр маси
float Radius;         // Наскільки далеко діє гравітація
float Strength;       // Наскільки сильно викривляється простір
float AspectRatio;    // Співвідношення сторін екрану (Ширина / Висота)

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color : COLOR0;
    float2 TextureCoordinates : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float2 uv = input.TextureCoordinates;
    
    float2 corrUV = uv;
    corrUV.x *= AspectRatio;
    
    float2 corrPlanetPos = PlanetPos;
    corrPlanetPos.x *= AspectRatio;

    float2 dir = corrPlanetPos - corrUV;
    float dist = length(dir);

    if (dist < Radius)
    {
        // Базовий плавний перехід
        float factor = smoothstep(Radius, 0.0, dist);
        
        // Рахуємо бажану силу зсуву
        float pullAmount = factor * Strength;
        
        // АНТИ-СИНГУЛЯРНІСТЬ (ПОМ'ЯКШЕННЯ ЦЕНТРУ)
        // Ми не дозволяємо зсуву бути більшим, ніж відстань до центру (dist).
        // Множник 0.85 залишає невелику "мертву зону" в центрі, 
        // роблячи ефект схожим на м'яке натягнення гуми, а не на чорну діру.
        // Змініть 0.85 на 0.5, щоб зробити центр ще більш плоским і м'яким.
        pullAmount = min(pullAmount, dist * 0.85);
        
        uv -= normalize(dir) * pullAmount;
    }

    return tex2D(SpriteTextureSampler, uv) * input.Color;
}

technique SpriteDrawing
{
    pass P0
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}