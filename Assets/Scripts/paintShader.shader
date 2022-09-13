Shader "Hidden/paintShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LastFrame ("Last Frame", 2D) = "black" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
            #pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            extern uniform sampler2D _MainTex;
            extern uniform sampler2D _LastFrame;

            extern uniform int _Precision;
            extern uniform int _Passes;

            extern uniform fixed _PassedTime;
            extern uniform fixed _Threshold;
            extern uniform fixed _GridOffset;

            fixed4 frag (v2f i) : SV_Target
            {

                //vars, coord just increases or decreases resolution based on _Precision var
                volatile fixed4 col = fixed4(0,0,0,0);

                //xOffset and yOffset
                fixed gridOffset = frac(sin(dot(float2(1 - .01f,2), float2(12.9898 * _PassedTime + .01f, 78.233))) * 43758.5453) * _GridOffset;

                //get x and y values and set them to the center of the screen
                fixed2 pos = abs(i.uv - .5f);

                //gets hypotenuse
                fixed h = sqrt(pow(pos.x,2) + pow(pos.y,2));

                //for loop generates different amounts of precision based on number of passes
                for(fixed j = 0.0f; j < _Passes; j++) {
                
                    //generates the level of precision this pass has
                    int p = _Precision * (pow(2,j) + gridOffset);
                
                    fixed2 coord = fixed2(round(i.uv * p) / p);
                
                    //creates a psudeo random number based on the current cell (NOT PIXEL)
                    //reason it is animated is because of _PassedTime var
                    //* h is to convert shape from random noise to a circle with noise
                    fixed rand = frac(sin(dot(fixed2(coord.x - .01f, coord.y), fixed2(12.9898 * _PassedTime, 78.233))) * 43758.5453) * h;
                
                    //checks if the pseudo random number is under a threshold, if it is draw the normal texture otherwise draw nothing
                    col = (rand < _Threshold) ? tex2D(_MainTex, coord) : col;
                }

                //checks if col is undefined, if it is then return last frame
                col = col.a == 0 ? tex2D(_LastFrame, i.uv) : col;

                return col;
            }
            ENDCG
        }
    }
}
