using Makie, GLMakie, GeometryBasics, Rotations

"""
    conformal_cubed_sphere_mapping(x, y)

Conformal mapping of a cube onto a sphere. Maps `(x, y)` on the north-pole face of a cube
to (X, Y, Z) coordinates in physical space. The face is oriented normal to Z-axis with
X and Y increasing with x and y.

The input coordinates must lie within the range -1 <= x <= 1,  -1 <= y <= 1.

This numerical conformal mapping is described by Rančić et al. (1996).

This is a Julia translation of MATLAB code from MITgcm [1] that is based on
Fortran 77 code from Jim Purser & Misha Rančić.

[1] http://wwwcvs.mitgcm.org/viewvc/MITgcm/MITgcm_contrib/high_res_cube/matlab-grid-generator/map_xy2xyz.m?view=markup
Author of conformal_cubed_sphere_mapping: ["ali.hh.ramadhan@gmail.com <ali.hh.ramadhan@gmail.com>"]
"""
A_Rancic = [
    +0.00000000000000,
    +1.47713062600964,
    -0.38183510510174,
    -0.05573058001191,
    -0.00895883606818,
    -0.00791315785221,
    -0.00486625437708,
    -0.00329251751279,
    -0.00235481488325,
    -0.00175870527475,
    -0.00135681133278,
    -0.00107459847699,
    -0.00086944475948,
    -0.00071607115121,
    -0.00059867100093,
    -0.00050699063239,
    -0.00043415191279,
    -0.00037541003286,
    -0.00032741060100,
    -0.00028773091482,
    -0.00025458777519,
    -0.00022664642371,
    -0.00020289261022,
    -0.00018254510830,
    -0.00016499474461,
    -0.00014976117168,
    -0.00013646173946,
    -0.00012478875823,
    -0.00011449267279,
    -0.00010536946150,
    -0.00009725109376
]

function conformal_cubed_sphere_mapping(x, y)
    X = xᶜ = abs(x)
    Y = yᶜ = abs(y)

    kxy = yᶜ > xᶜ

    xᶜ = 1 - xᶜ
    yᶜ = 1 - yᶜ

    kxy && (xᶜ = 1 - Y)
    kxy && (yᶜ = 1 - X)

    Z = ((xᶜ + im * yᶜ) / 2)^4
    W = W_Rancic(Z)

    im³ = im^(1/3)
    ra = √3 - 1
    cb = -1 + im
    cc = ra * cb / 2

    W = im³ * (W * im)^(1/3)
    W = (W - ra) / (cb + cc * W)
    X, Y = reim(W)

    H = 2 / (1 + X^2 + Y^2)
    X = X * H
    Y = Y * H
    Z = H - 1

    if kxy
        X, Y = Y, X
    end

    y < 0 && (Y = -Y)
    x < 0 && (X = -X)

    # Fix truncation for x = 0 or y = 0.
    x == 0 && (X = 0)
    y == 0 && (Y = 0)

    return X, Y, Z
end

W_Rancic(Z) = sum(A_Rancic[k] * Z^(k-1) for k in 1:length(A_Rancic))


function cubed_sphere_warp(
    a,
    b,
    c,
    R = max(abs(a), abs(b), abs(c)),
)

    # @show (a,b,c)
    fdim = argmax(abs.((a, b, c)))
    # @show fdim
    M = max(abs.((a, b, c))...)
    if fdim == 1 && a < 0
        # left face
        x1, x2, x3 = conformal_cubed_sphere_mapping(-b / M, c / M)
        x1, x2, x3 = RotX(π/2) * RotY(-π/2) * [x1, x2, x3]
    elseif fdim == 2 && b < 0
        # front face
        x1, x2, x3 = conformal_cubed_sphere_mapping(a / M, c / M)
        x1, x2, x3 = RotX(π/2) * [x1, x2, x3]
    elseif fdim == 1 && a > 0
        # right face
        x1, x2, x3 = conformal_cubed_sphere_mapping(b / M, c / M)
        x1, x2, x3 = RotX(π/2) * RotY(π/2) * [x1, x2, x3]
    elseif fdim == 2 && b > 0
        # back face
        x1, x2, x3 = conformal_cubed_sphere_mapping(a / M, -c / M)
        x1, x2, x3 = RotX(-π/2) * [x1, x2, x3]
    elseif fdim == 3 && c > 0
        # top face
        x1, x2, x3 = conformal_cubed_sphere_mapping(a / M, b / M)
    elseif fdim == 3 && c < 0
        # bottom face
        x1, x2, x3 = conformal_cubed_sphere_mapping(a / M, -b / M)
        x1, x2, x3 = RotX(π) * [x1, x2, x3]
    else
        error("invalid case for cubed_sphere_warp(::ConformalCubedSphere): $a, $b, $c")
    end

    return x1 * R, x2 * R, x3 * R

end

n = 6

r = range(-1,1,length=n+1)

xa = zeros(n+1,n+1)
xb = zeros(n+1,n+1)
xc = zeros(n+1,n+1)

# top face coordinates
xa .= r
xb .= r'
xc .= 1

a = [cubed_sphere_warp(a,b,c)[1] for (a,b,c) in zip(xa,xb,xc)]
b = [cubed_sphere_warp(a,b,c)[2] for (a,b,c) in zip(xa,xb,xc)]
c = [cubed_sphere_warp(a,b,c)[3] for (a,b,c) in zip(xa,xb,xc)]

sc = Scene(limits = HyperRectangle(Vec3f0(-2), Vec3f0(2)))

wireframe!(sc,
           a,b,c,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           a,b,-c,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           c,a,b,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           -c,a,b,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           b,c,a,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           b,-c,a,
           show_axis=false,
           linewidth=1.2)

sc
