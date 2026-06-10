// =====================================================
// 조립 씬 — 풀리 내장형 벨트 감속 관절 모듈
// DESIGN.md 6장 부품 리스트(#1~#18)를 한글 라벨로 표기
//
// 미리보기:  openscad scad/assembly.scad
// PNG 렌더:  xvfb-run -a openscad -o render.png \
//            --imgsize=1600,1200 --camera=<...> scad/assembly.scad
// show_labels=false 로 라벨 숨김 가능
// =====================================================

include <params.scad>
include <motor_side.scad>
include <output_side.scad>

show_labels = true;
label_font = "Noto Sans CJK KR";   // 한글 폰트 (Windows: "Malgun Gothic")
label_size = 4.8;

// ---- 라벨: 지시선 + 빌보드 텍스트 ----
module label(txt, anchor, off, halign = "left") {
    if (show_labels) color([0.05, 0.05, 0.05]) {
        hull() {
            translate(anchor) sphere(0.7);
            translate(anchor + off) sphere(0.4);
        }
        translate(anchor + off) rotate($vpr)
            translate([halign == "left" ? 2 : -2, -1.5, 0])
                linear_extrude(0.6)
                    text(txt, size = label_size, font = label_font,
                         halign = halign);
    }
}

// ---- 1/4 단면 컷 (부품별 적용 — 절단면이 부품색으로 보이도록 커터에 색 지정) ----
// d: 절단 깊이 오프셋 — 부품마다 달리해 단면 z-fighting 방지(안쪽 부품일수록 작게)
module cutaway(c, d = 0.3) {
    difference() {
        children();
        // +x / -y 사분면 컷 (암 본체는 x>30이라 유지됨)
        color(c) translate([-d, -60, -16]) cube([30 + d, 60 + d, 75]);
    }
}

// ---- 출력축 어셈블리 (내부 적층 노출) ----
module output_assembly() {
    cutaway(c_steel, 0)     stripper_bolt();             // #5
    cutaway(c_steel, 0.25)  bearing_608(lower_brg_z0);   // #6
    cutaway(c_steel, 0.25)  bearing_608(upper_brg_z0);   // #6
    cutaway(c_alu, 0.25)    inner_spacer();              // #7
    cutaway(c_alu, 0.25)    standoff_spacer();           // #8
    cutaway(c_alu, 0.25)    shim_washer();               // #9
    cutaway(c_steel, 0.25)  top_washer();                // #10
    cutaway(c_steel, 0.25)  head_washer();               // #10
    cutaway(c_print, 0.8)   arm_hub();                   // #16
    cutaway(c_alu, 0.5)     pulley60();                  // #3
    cutaway(c_print2, 0.5)  clamp_ring();                // #17
    pulley_bolts();                               // #12 + #13
    m6_top_nut();                                 // #18
}

// ---- 전체 조립 ----
base_plate();      // #15
nema17();          // #1
pulley20();        // #2
motor_bolts();     // #11
jack_screw();      // #14
belt();            // #4
output_assembly();

// ---- 부품 리스트 라벨 (DESIGN.md 6장 번호) ----
// 텍스트 시작점을 좌/우 고정 칼럼(x ≈ ±34 / -78)에 정렬해 가독성 확보
// 모터 측 (왼쪽 칼럼, 오른쪽 정렬)
label("4 타이밍 벨트 GT2-280",   [-60, -12, 12],   [-18, -6, 28],  "right");
label("2 입력 풀리 GT2 20T",     [-104, -5, 12],   [-16, -13, 20], "right");
label("1 스테퍼 모터 NEMA 17",   [-110, -18, -25], [-18, -6, -5],  "right");
label("11 모터 체결 볼트 M3×12", [-84, -15.5, 2],  [-28, -10.5, -20], "right");
label("14 잭 스크류 M3×20",      [-56, -1, -15],   [-29, -29, -35], "right");
label("17 클램프 링",             [-18, -18, 6.5],  [-18, -22, -62.5], "right");
label("3 출력 풀리 GT2 60T",     [-13.4, -13.4, 12.5], [3.4, -26.6, -58.5], "right");
label("15 베이스 플레이트",       [-45, -15.5, -5], [27, -31.5, -29]);

// 출력축 적층 (오른쪽 세로 칼럼 x=36, 위→아래 등간격 z 9)
label("5 스트리퍼 볼트 Ø8×L55", [0.5, -2.5, 53],  [35.5, -21.5, 17]);
label("18 M6 나일록 너트",       [4.5, -2, 49],    [31.5, -22, 12]);
label("10 M8 평와셔 ×2",         [7.5, -1, 45.5],  [28.5, -23, 6.5]);
label("9 심 와셔",               [6.5, -1, 44.3],  [29.5, -23, -1.3]);
label("6 베어링 608ZZ ×2",      [10, -1, 40.5],   [26, -23, -6.5]);
label("7 내륜 스페이서 8×10×10", [4.8, -1, 32],    [31.2, -23, -7]);
label("8 스탠드오프 스페이서 ×2", [4.8, -1, 10],    [31.2, -23, 6]);
// 12·13은 베이스 앞면 모서리 바깥으로 빼서 가림 방지
label("12 풀리 체결 볼트 M3×16", [12.5, -21.7, 22], [37.5, -26.3, -27]);
label("13 M3 육각 너트",         [12.5, -21.7, 6.8], [31.5, -26.3, -24.8]);
label("16 암 허브 / 암",          [75, 3, 42],      [5, -27, -37]);
