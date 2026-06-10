// =====================================================
// 조립 씬 — 풀리 내장형 벨트 감속 관절 모듈 (회전축 구조)
// DESIGN.md 6장 부품 리스트를 한글 라벨로 표기
// (#8 스탠드오프·#12·#17 클램프 계통은 회전축 재설계로,
//  #9 심 와셔는 허브 증육 + 광폭 와셔 변경으로 결번)
//
// 미리보기:  openscad scad/assembly.scad
// PNG 렌더:  xvfb-run -a openscad -o render.png \
//            --imgsize=1600,1200 --camera=<...> scad/assembly.scad
// show_labels=false 로 라벨 숨김 가능
// show_cutaway=false 로 1/4 단면 끄기 가능
// =====================================================

include <params.scad>
include <motor_side.scad>
include <output_side.scad>

/* [표시 옵션] */
// 부품 라벨 (지시선 + 빌보드 텍스트) 표시
show_labels = true;
// 1/4 단면을 반투명 고스트로 표시
show_cutaway = true;
// 단면 고스트 기본 투명도 (겉을 감싸는 부품은 cutaway()의 ga 인자로 차등)
ghost_alpha = 0.30; // [0.05:0.05:1]
// 한글 라벨 폰트 (Windows: "Malgun Gothic")
label_font = "Noto Sans CJK KR";
// 라벨 글자 크기
label_size = 4.8; // [3:0.1:8]

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

// ---- 1/4 단면 — 잘라내는 대신 반투명 고스트로 표시 ----
// show_cutaway=false 로 단면 없이 통짜 표시
// d: 절단 깊이 오프셋 — 부품마다 달리해 단면 z-fighting 방지(안쪽 부품일수록 작게)
// 불투명 본체(3/4) + 같은 형상의 1/4을 $ghost_alpha 투명도로 겹침
module _quarter_cutter(c, d) {
    // +x / -y 사분면 (암 본체는 x>30이라 유지됨), z는 너트 위~머리 아래 커버
    color(c) translate([-d, -60, -34]) cube([30 + d, 60 + d, 96]);
}
// ga: 부품별 고스트 투명도 — 겉을 감싸는 큰 부품일수록 투명하게
module cutaway(c, d = 0.3, ga = ghost_alpha) {
    if (show_cutaway) {
        difference() {
            children();
            _quarter_cutter(c, d);
        }
        let($ghost_alpha = ga)
            intersection() {
                children();
                color(c, ga) translate([-d - 0.05, -60, -34]) cube([30 + d, 60, 96]);
            }
    } else {
        color(c) children();
    }
}

// ---- 출력축 어셈블리 (회전 적층 노출) ----
module output_assembly() {
    // 베어링 (베이스 보스 안 — 외륜 고정, 내륜 회전)
    cutaway(c_steel, 0.25, 0.4) bearing_608(brgA_z0);   // #6 상부
    cutaway(c_steel, 0.25, 0.4) bearing_608(brgB_z0);   // #6 하부

    // 회전 적층 (스트리퍼 볼트 머리 하향, 너트가 전체를 클램프)
    cutaway(c_axle, 0)      stripper_bolt();         // #5
    cutaway(c_alu, 0.25)    inner_spacer();          // #7
    cutaway(c_washer, 0.25) head_washer();           // #10
    cutaway(c_washer, 0.25) mid_washer();            // #10
    cutaway(c_washer, 0.25) top_washer();            // #10
    cutaway(c_move_m, 0.5, 0.16) pulley60();         // #3
    cutaway(c_move, 0.8, 0.13)  arm_hub();           // #16
    m6_top_nut();                                    // #18
}

// ---- 전체 조립 ----
base_plate();      // #15 (베어링 보스 일체)
nema17();          // #1
pulley20();        // #2
motor_bolts();     // #11
jack_screw();      // #14
belt();            // #4
output_assembly();

// ---- 부품 리스트 라벨 (DESIGN.md 6장 번호) ----
// 텍스트 시작점을 좌/우 칼럼에 정렬해 가독성 확보
// 모터 측 (왼쪽 칼럼, 오른쪽 정렬) — 앵커는 모터 중심(-axis_dist) 상대 좌표
label(str("4 타이밍 벨트 GT2-", belt_len),
      [-axis_dist * 0.6, -12, 12], [-axis_dist * 0.4 - 20.8, -6, 30], "right");
label("2 입력 풀리 GT2 20T",     [-axis_dist - 4.8, -5, 12],    [-16, -13, 20], "right");
label("1 스테퍼 모터 NEMA 17",   [-axis_dist - 10.8, -18, -25], [-18, -6, -16], "right");
label("11 모터 체결 볼트 M3×12", [-axis_dist + 15.5, -15.5, 2], [-28, -10.5, 14], "right");
label("14 잭 스크류 M3×20",      [-axis_dist + 43.2, -1, -15],  [-29, -29, -35], "right");
label("13 M3 육각 너트",         [-axis_dist + 28.2, -1.5, -15],
      compact_base ? [25.4, -32.5, -43] : [21, -24.5, -27]);   // 컴팩트는 하단 중앙이 좁아 우하단으로
label("3 출력 풀리 GT2 60T",     [-13.4, -13.4, 12.5], [3.4, -26.6, -58.5], "right");
label("15 베이스 플레이트",       [-45, -15.5, -5], [27, -31.5, -29]);

// 출력축 적층 (오른쪽 세로 칼럼 x=36 — 위 그룹: 너트~허브 / 아래 그룹: 보스 안)
// #10 평와셔는 위치별 규격이 달라 3개를 각각 지시
label("18 M6 나일록 너트",          [4.5, -2, 35.3],  [31.5, -22, 26.7]);
label("10 상부 평와셔 M6×22×2.0",   [10, -1, 31.3],   [26, -23, 21.7]);
label("16 암 허브 / 암",             [75, 3, 27],      [5, -27, 18]);
label("10 중간 평와셔 M8×15×1.6",   [6.5, -1, 0.8],   [29.5, -23, 8.2]);
label("6 베어링 608ZZ ×2",         [10, -1, -3.5],   [26, -23, -8.5]);
label("7 내륜 스페이서 8×10×10",    [4.8, -1, -12],   [31.2, -23, -9]);
label("10 머리측 평와셔 M8×15×1.6", [5.5, -1, -24.8], [30.5, -23, -5.2]);
label("5 스트리퍼 볼트 Ø8×L55",    [3, -3, -28],     [33, -21, -11]);
