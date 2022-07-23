        
// if this macro processor is not defined, define it. but if shadergraph comes looking for it again its already defined so dont.
#ifndef _OCTAVEGRADIENTNOISE_INC
#define _OCTAVEGRADIENTNOISE_INC
        float random(float2 v)
        {
            return frac(sin(dot(v.xy, float2(12.9898, 78.233))) * 43758.5453123);
        }

        float2 randomDir(float2 v)
        {
            return float2(random(v), random(v * 2.0f)) * 2.0f - 1.0f;
        }

        //grid directions
        static const float2 s_dirs[4] = {
            float2(0.0, 0.0),
            float2(1.0, 0.0),
            float2(0.0, 1.0),
            float2(1.0, 1.0)
        };

        float noise(float2 v)
        {
            //integer component of this sample, the id of our "grid cell"
            float2 i = floor(v);
            //decimal component of this sample, the position within a "grid cell"
            float2 f = frac(v);
            //smooth out the fractional component into a smooth gradient
            float2 s = smoothstep(0., 1., f);

            //assign 4 random dirs for this grid cell
            float2 randDir0 = randomDir(i + s_dirs[0]);
            float2 randDir1 = randomDir(i + s_dirs[1]);
            float2 randDir2 = randomDir(i + s_dirs[2]);
            float2 randDir3 = randomDir(i + s_dirs[3]);

            //current position of this sample in each cell
            float2 cellPos0 = f - s_dirs[0];
            float2 cellPos1 = f - s_dirs[1];
            float2 cellPos2 = f - s_dirs[2];
            float2 cellPos3 = f - s_dirs[3];

            //project all the current positions in the respective cells with their random directions
            float p0 = dot(randDir0, cellPos0);
            float p1 = dot(randDir1, cellPos1);
            float p2 = dot(randDir2, cellPos2);
            float p3 = dot(randDir3, cellPos3);

            //biliearly interpolate the result
            return lerp(lerp(p0, p1, s.x), lerp(p2, p3, s.x), s.y);
        }

        float octaveNoise(float2 v, int octaves)
        {
            float n = 0.0f;
            float fq = 1.f;
            float amplitude = 1.f;
            for (int i = 0; i < octaves; ++i)
            {
                n += noise(v * fq) * amplitude;
                fq *= 2.0f;
                amplitude *= .5f;
            }
            return n * 0.5f + 0.5f;
        }

void OctaveGradientNoise_float(in float2 pos, in int octaves, out float n)
{
    n = octaveNoise(pos, octaves);
}

#endif
