// =====================================================
// 프린팅 부품 단품 배치 — STL 내보내기 / 슬라이싱용
//
// 사용:
//   openscad -o base.stl  -D 'part="base"'  scad/print_parts.scad
//   openscad -o hub.stl   -D 'part="hub"'   scad/print_parts.scad
//   part="all" 이면 베드 배치로 한꺼번에 보기
//
// 프린팅 방향 (전 부품 서포트 불필요):
//   base — 윗면을 베드에 (잭 블록·베어링 보스·웨이스트 리브가 위로,
//          트렌치는 3.5mm 브리지, 베어링 포켓 사이 웹은 1mm 링 브리지,
//          잭 너트 포켓은 꼭짓점-업 육각이라 60° 벽으로 출력됨)
//   hub  — 암 윗면을 베드에 (허브 Ø32 = 암 폭이라 오버행 없음, 평면 부품)
// =====================================================

include <params.scad>
include <motor_side.scad>
include <output_side.scad>

/* [출력 부품 선택] */
// 내보낼 부품 (all = 베드 배치로 한꺼번에 미리보기)
part = "all"; // ["all", "base", "hub"]

module print_base() { rotate([180, 0, 0]) base_plate(); }                  // 윗면이 베드
module print_hub()  { translate([0, 0, arm_z1]) rotate([180, 0, 0]) arm_hub(); }

if (part == "base") print_base();
if (part == "hub")  print_hub();
if (part == "all") {
    print_base();
    translate([60, 70, 0]) print_hub();
}
