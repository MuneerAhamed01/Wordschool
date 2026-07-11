/**
 * Matches Dart's String.hashCode so server-side game seeding picks the same word.
 */
export function dartStringHashCode(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i++) {
    const codeUnit = value.charCodeAt(i);
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 5));
    hash = hash ^ (hash >> 27);
  }
  hash = 0x1fffffff & hash;
  return hash === 0 ? 1 : hash;
}
