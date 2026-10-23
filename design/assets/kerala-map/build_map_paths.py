import json, sys
from shapely.geometry import shape, Polygon, MultiPolygon, LineString, MultiLineString, Point
from shapely.ops import unary_union

src = sys.argv[1]
out = sys.argv[2]
COS = 0.983

def P(lon, lat):
    return ((lon - 74.80) * 100 * COS, (12.85 - lat) * 100)

def proj_geom(g):
    if isinstance(g, Polygon):
        return Polygon([P(*c) for c in g.exterior.coords], [[P(*c) for c in r.coords] for r in g.interiors])
    if isinstance(g, MultiPolygon):
        return MultiPolygon([proj_geom(p) for p in g.geoms])
    raise ValueError(g.geom_type)

SC = 2  # output space is x2 projected units, integers, relative moves

def enc(pts, close):
    q = [(int(round(x * SC)), int(round(y * SC))) for x, y in pts]
    out = [q[0]]
    for p in q[1:]:
        if p != out[-1]:
            out.append(p)
    if close and len(out) > 1 and out[-1] == out[0]:
        out = out[:-1]
    if len(out) < 2:
        return ''
    s = 'M%d %d' % out[0]
    px, py = out[0]
    for x, y in out[1:]:
        dx, dy = x - px, y - py
        s += 'l%d%s%d' % (dx, ' ' if dy >= 0 else '', dy)
        px, py = x, y
    return s + ('z' if close else '')

def ring_d(coords):
    return enc(list(coords), True)

def poly_d(g, tol):
    g = g.simplify(tol, preserve_topology=True)
    polys = [g] if isinstance(g, Polygon) else list(getattr(g, 'geoms', []))
    d = ''
    for p in polys:
        if not isinstance(p, Polygon) or p.area < 1.0:
            continue
        d += ring_d(p.exterior.coords)
    return d

def line_d(g, tol):
    g = g.simplify(tol)
    lines = [g] if isinstance(g, LineString) else [x for x in getattr(g, 'geoms', []) if isinstance(x, LineString)]
    d = ''
    for l in lines:
        c = list(l.coords)
        if len(c) < 2 or l.length < 4:
            continue
        d += enc(c, False)
    return d

dist = json.load(open(src + '/district.geojson'))
districts = []
geoms = []
for f in dist['features']:
    g = proj_geom(shape(f['geometry'])).buffer(0)
    geoms.append(g)
    rp = g.representative_point()
    c = g.centroid
    districts.append({'name': f['properties']['DISTRICT'], 'g': g, 'cx': round(c.x, 1), 'cy': round(c.y, 1), 'rx': round(rp.x, 1), 'ry': round(rp.y, 1)})

state = unary_union(geoms).buffer(0.3).buffer(-0.3)
if isinstance(state, MultiPolygon):
    main = max(state.geoms, key=lambda p: p.area)
else:
    main = state

# split outer ring into coast (west chain) and land border (east chain)
ring = list(main.exterior.coords)[:-1]
iN = min(range(len(ring)), key=lambda i: ring[i][1])
iS = max(range(len(ring)), key=lambda i: ring[i][1])
def chain(a, b):
    out = []
    i = a
    while True:
        out.append(ring[i])
        if i == b:
            break
        i = (i + 1) % len(ring)
    return out
c1, c2 = chain(iN, iS), chain(iS, iN)
mean_x = lambda ch: sum(p[0] for p in ch) / len(ch)
coast, border = (c1, c2) if mean_x(c1) < mean_x(c2) else (c2, c1)
border_line = LineString(border)

# stylised terrain from distance to the eastern (Ghats) border, with the Palakkad Gap carved out
gapc = Point(P(76.82, 10.82))
gap = gapc.buffer(12).union(LineString([P(76.55, 10.80), P(77.0, 10.84)]).buffer(10))
high = main.intersection(border_line.buffer(17)).difference(gap)
peak = main.intersection(border_line.buffer(8)).difference(gap.buffer(6))
mid = main.intersection(border_line.buffer(40)).difference(high)
contours = []
for r in (5, 10, 15, 22, 30):
    ring_line = border_line.buffer(r).exterior
    seg = ring_line.intersection(main.buffer(-1.2)).difference(gap.buffer(2))
    contours.append(line_d(seg, 0.6))

res = {
    'bounds': [round(v, 1) for v in main.bounds],
    'state': poly_d(main, 0.3),
    'vembanad': enc([P(*p) for p in [(76.30,9.98),(76.33,9.90),(76.36,9.80),(76.38,9.72),(76.40,9.64),(76.40,9.57),(76.43,9.52),(76.42,9.60),(76.43,9.68),(76.42,9.76),(76.40,9.84),(76.37,9.92),(76.33,9.99)]], True),
    'coast': line_d(LineString(coast), 0.35),
    'border': line_d(border_line, 0.35),
    'high': poly_d(high, 0.5),
    'peak': poly_d(peak, 0.5),
    'mid': poly_d(mid, 0.5),
    'contours': contours,
    'districts': [{'name': d['name'], 'd': poly_d(d['g'], 0.5), 'rx': round(d['rx']*2), 'ry': round(d['ry']*2),
                   'bounds': [round(v*2) for v in d['g'].bounds]} for d in districts],
}
json.dump(res, open(out, 'w'))
print('bounds', res['bounds'])
print('state len', len(res['state']), 'districts total', sum(len(d['d']) for d in res['districts']))
for d in res['districts']:
    print(d['name'], d['rx'], d['ry'], d['bounds'], len(d['d']))
