Shader "Custom/Grass Geometry"{
    Properties{
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Cutoff", Range(0,1)) = 0.25
        _GrassHeight("Grass Height", Float) = 0.25
        _GrassWidth("Grass Width", Float) = 0.25
        _WindSpeed("Wind Speed", Float) = 100
        _WindStrength("Wind Strength", Float) = 0.05
    }
    SubShader{
        Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        LOD 400
        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CULL OFF
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight            
            #pragma target 4.0
            
            sampler2D _MainTex;

            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2g{
                float4 pos : SV_POSITION;
                float3 norm : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct g2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) //shadow info in TEXCOORD1
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
            };

            float4 _Color;
            half _GrassHeight;
            half _GrassWidth;
            half _Cutoff;
            half _WindStrength;
            half _WindSpeed;

            void setVertex(float3 p, float3 a, float3 n, float2 uv, inout TriangleStream<g2f> triStream){ //This is essentially our vertex shader in disguise
                g2f OUT;
                OUT.pos = UnityObjectToClipPos(p + a * 0.5 * _GrassHeight);
                OUT.uv = uv;
                half nl = max(0, dot(n, _WorldSpaceLightPos0.xyz));
                OUT.diff = nl * _LightColor0.rgb;
                OUT.ambient = ShadeSH9(half4(n, 1));
                TRANSFER_SHADOW(OUT)
                triStream.Append(OUT);
            }

            void renderQuad(float3 N, float3 v0, float3 v1, float3 angle, inout TriangleStream<g2f> triStream){
                float3 zeros = float3(0.0,0.0,0.0);
                //positive
                setVertex(v0, angle, N, float2(1,0), triStream);
                setVertex(v1, angle, N, float2(1,1), triStream);
                //center
                setVertex(v0, zeros, N, float2(0.5,0), triStream);
                setVertex(v1, zeros, N, float2(0.5,1), triStream);
                //negative
                setVertex(v0, -angle, N, float2(0,0), triStream);
                setVertex(v1, -angle, N, float2(0,1), triStream);
                //center
                setVertex(v0, zeros, N, float2(0.5,0), triStream);
                setVertex(v1, zeros, N, float2(0.5,1), triStream);
            }

            v2g vert(appdata v){
                v2g OUT;
                OUT.pos = v.vertex;
                OUT.norm = v.normal;
                OUT.uv = v.texcoord;
                return OUT;
            }

            [maxvertexcount(24)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream){
                float3 perpendicularAngle = float3(0,0,1);
                //float3 faceNormal = UnityObjectToWorldNormal(cross(perpendicularAngle, IN[0].norm)); //this is what it should be, however lighting is unhappy
                float3 faceNormal = float3(0,1,0);

                float3 v0 = IN[0].pos.xyz;
                float3 v1 = IN[0].pos.xyz + IN[0].norm*_GrassHeight;

                float sin60 = 0.866f; float cos60 = 0.5f;

                renderQuad(faceNormal, v0, v1, perpendicularAngle, triStream);
                renderQuad(faceNormal, v0, v1, float3(sin60, 0, -cos60), triStream);
                renderQuad(faceNormal, v0, v1, float3(sin60, 0, cos60), triStream);
            }

            half4 frag(g2f IN) : SV_TARGET
            {
                fixed4 c = tex2D(_MainTex, IN.uv) * _Color;
                fixed att = SHADOW_ATTENUATION(IN);
                fixed3 lighting = IN.diff * att + IN.ambient;
                c.rgb *= lighting;
                clip(c.a - _Cutoff);
                return c;
            }
            ENDCG
        }

        //Shadow Caster
        Pass{
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            Fog {Mode Off}
            ZWrite On ZTest LEqual
            CULL OFF

            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma target 4.0

            struct v2g{
                V2F_SHADOW_CASTER;
                float3 norm : NORMAL;
            };

            struct g2f{
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD2;
            };
            sampler2D _MainTex;
            half _GrassHeight;
            half _GrassWidth;
            half _Cutoff;
            half _WindStrength;
            half _WindSpeed;

            void setVertex(float3 p, float3 a, float2 uv, inout TriangleStream<g2f> triStream){
                g2f OUT; OUT.uv = uv;
                OUT.pos = UnityObjectToClipPos(p + a * 0.5 * _GrassHeight);
                triStream.Append(OUT);
            }

            void renderQuad(float3 v0, float3 v1, float3 angle, inout TriangleStream<g2f> triStream){
                float3 zeros = float3(0.0,0.0,0.0);
                //positive
                setVertex(v0, angle, float2(1,0), triStream);
                setVertex(v1, angle,float2(1,1), triStream);
                //center
                setVertex(v0, zeros, float2(0.5,0), triStream);
                setVertex(v1, zeros,float2(0.5,1), triStream);
                //negative
                setVertex(v0, -angle, float2(0,0), triStream);
                setVertex(v1, -angle, float2(0,1), triStream);
                //center
                setVertex(v0, zeros, float2(0.5,0), triStream);
                setVertex(v1, zeros, float2(0.5,1), triStream);
            }

            v2g vert(appdata_full v){
                v2g OUT = (v2g)0;
                OUT.pos = v.vertex;
                OUT.norm = v.normal;
                return OUT;
            }

            [maxvertexcount(24)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream){
                float3 perpendicularAngle = float3(0,0,1);
                float3 v0 = IN[0].pos.xyz;
                float3 v1 = IN[0].pos.xyz + IN[0].norm*_GrassHeight;

                float sin60 = 0.866f; float cos60 = 0.5f;

                renderQuad(v0, v1, perpendicularAngle, triStream);
                renderQuad(v0, v1, float3(sin60, 0, -cos60), triStream);
                renderQuad(v0, v1, float3(sin60, 0, cos60), triStream);
            }

            half4 frag(g2f IN) : COLOR
            {
                fixed4 C = tex2D(_MainTex, IN.uv);
                clip(C.a - _Cutoff);
                SHADOW_CASTER_FRAGMENT(IN);
            }
            ENDCG
        }
    }
}