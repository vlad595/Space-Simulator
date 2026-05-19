#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

sampler2D SpriteTextureSampler : register(s0);

float2 BallPos;       // Позиція м'яча на екрані
float Radius;         // Радіус, в межах якого тканина реагує
float Mass;           // Маса м'яча (рекомендовано від 0.0 до 1.0, чим більше - тим глибша яма)
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
    
    // Коректуємо координати для збереження правильних пропорцій (щоб прогин був круглим, а не овальним)
    float2 corrUV = uv;
    corrUV.x *= AspectRatio;
    
    float2 corrBallPos = BallPos;
    corrBallPos.x *= AspectRatio;

    // Вектор від поточного пікселя до центру м'яча
    float2 dir = corrBallPos - corrUV;
    float dist = length(dir);

    // Беремо стандартний колір, якщо ми поза зоною впливу
    float4 color = tex2D(SpriteTextureSampler, uv);

    // Якщо піксель знаходиться в радіусі прогинання тканини
    if (dist < Radius)
    {
        // Нормалізована відстань (від 0.0 у центрі до 1.0 на краях)
        float normDist = dist / Radius;
        
        // Формула прогинання. Використовуємо smoothstep для плавних країв,
        // а потім підносимо до квадрата, щоб створити форму "воронки" (тканина тягнеться експоненціально)
        float falloff = 1.0 - smoothstep(0.0, 1.0, normDist);
        float curve = falloff * falloff;
        
        // Розраховуємо силу зсуву UV-координат. Маса посилює ефект розтягування.
        float pullAmount = curve * Mass * 0.15; 
        pullAmount = min(pullAmount, dist * 0.9);
        
        // 1. Отримуємо вектор зсуву
        float2 offset = normalize(dir) * pullAmount;
        
        // 2. ВАЖЛИВО: Повертаємо зміщення по осі X назад у нормалізований UV-простір
        offset.x /= AspectRatio;
        
        // 3. Зсуваємо UV-координати
        float2 distortedUV = uv - offset;
        
        // Отримуємо колір з нових, зміщених координат
        color = tex2D(SpriteTextureSampler, distortedUV);
        
        // --- 3D ЕФЕКТ (ТІНЬ) ---
        // Чим глибше прогинається тканина (більша маса та ближче до центру), тим темніше.
        // Це критично важливо, щоб ефект виглядав як об'ємна тканина, а не просто як лінза.
        float depthShadow = 1.0 - (curve * Mass * 0.8);
        depthShadow = clamp(depthShadow, 0.2, 1.0); // Запобігаємо абсолютно чорному кольору в центрі
        
        color.rgb *= depthShadow;
    }

    // Множимо на input.Color для підтримки стандартної зміни кольору через SpriteBatch
    return color * input.Color;
}

technique SpriteDrawing
{
    pass P0
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}