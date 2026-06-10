include <params.scad>

// =====================================================
// 모터 측 + 베이스 부품 모듈
// 모든 모듈은 전역 좌표계에 이미 배치된 상태로 그림
//  - 베이스 윗면 z=0, 출력축 중심 (0,0), 모터축 중심 (-axis_dist, 0)
// =====================================================

// ---- 내부 헬퍼: x방향 장공 2D (폭 w, 전체 길이 l, 끝 둥글게) ----
module _slot2d_x(w, l) {
    hull() {
        translate([-(l - w) / 2, 0]) circle(d = w);
        translate([ (l - w) / 2, 0]) circle(d = w);
    }
}

// -----------------------------------------------------
// 1. 베이스 플레이트 (프린팅)
// -----------------------------------------------------
module base_plate() {
    color(c_print)
    difference() {
        union() {
            // 본체: 모서리 둥근 플레이트, z -base_t..0
            translate([0, 0, -base_t])
                linear_extrude(height = base_t)
                    offset(r = base_corner_r)
                        translate([(base_x_min + base_x_max) / 2, 0])
                            square([base_x_max - base_x_min - 2 * base_corner_r,
                                    2 * base_y_half - 2 * base_corner_r],
                                   center = true);
            // 잭 스크류 블록: 베이스 윗면 위 z 0..jack_block[2]
            translate([jack_block_x, 0, jack_block[2] / 2])
                cube(jack_block, center = true);
        }

        // 출력축 M6 관통홀 Ø6.5 (원점)
        translate([0, 0, -base_t - 1])
            cylinder(d = 6.5, h = base_t + 2);

        // 모터 체결 슬롯 4개 (모터축 기준 ±nema_hole_pitch/2)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([-axis_dist + sx * nema_hole_pitch / 2,
                       sy * nema_hole_pitch / 2, -base_t - 1])
                linear_extrude(height = base_t + 2)
                    _slot2d_x(slot_w, slot_l);

        // 센터 보스 장공 (모터축 중심, 폭 y방향 boss_slot_w, x방향 길이 boss_slot_l)
        translate([-axis_dist, 0, -base_t - 1])
            linear_extrude(height = base_t + 2)
                _slot2d_x(boss_slot_w, boss_slot_l);

        // 잭 블록 M3 관통홀 (x방향, 블록 중앙 높이)
        translate([jack_block_x - jack_block[0] / 2 - 1, 0, jack_block[2] / 2])
            rotate([0, 90, 0])
                cylinder(d = 3.4, h = jack_block[0] + 2);

        // 육각 너트 포켓 자국 (+x쪽 면, 폭간 5.5 → 외접경 5.5/cos(30))
        translate([jack_block_x + jack_block[0] / 2 - 1.5, 0, jack_block[2] / 2])
            rotate([0, 90, 0])
                cylinder(d = 5.5 / cos(30), h = 1.6, $fn = 6);
    }
}

// -----------------------------------------------------
// 2. NEMA 17 모터 (베이스 아래 매달림)
// -----------------------------------------------------
module nema17() {
    // 몸체: 모서리 약간 깎인 정사각 단면 × nema_len
    color(c_motor)
    translate([-axis_dist, 0, -base_t - nema_len])
        linear_extrude(height = nema_len)
            offset(r = 2) offset(delta = -2)   // 모서리 R2
                intersection() {               // 코너 45도 컷
                    square(nema_side, center = true);
                    rotate(45) square(nema_side * 1.28, center = true);
                }

    // 위치결정 보스
    color(c_motor)
    translate([-axis_dist, 0, -base_t])
        cylinder(d = nema_boss_d, h = nema_boss_h);

    // 모터축
    color(c_steel)
    translate([-axis_dist, 0, -base_t])
        cylinder(d = nema_shaft_d, h = nema_shaft_top + base_t);
}

// -----------------------------------------------------
// 3. GT2 20T 입력 풀리 (모터축 위)
// -----------------------------------------------------
module pulley20() {
    color(c_alu)
    translate([-axis_dist, 0, 0])
        difference() {
            union() {
                // 아래 플랜지
                translate([0, 0, p20_z0])
                    cylinder(d = p20_flange_d, h = belt_z0 - p20_z0);
                // 이빨부 (원통 단순화, 벨트 구간)
                translate([0, 0, belt_z0])
                    cylinder(d = p20_od, h = belt_w);
                // 위 플랜지
                translate([0, 0, belt_z0 + belt_w])
                    cylinder(d = p20_flange_d, h = 1.0);
                // 세트스크류 허브보스
                translate([0, 0, belt_z0 + belt_w + 1.0])
                    cylinder(d = 10, h = p20_z1 - (belt_z0 + belt_w + 1.0));
            }
            // bore Ø5
            translate([0, 0, p20_z0 - 1])
                cylinder(d = 5, h = p20_z1 - p20_z0 + 2);
        }
}

// -----------------------------------------------------
// 4. 모터 체결 볼트 M3×8 + 대형와셔 4개
// -----------------------------------------------------
module motor_bolts() {
    color(c_steel)
    for (sx = [-1, 1], sy = [-1, 1])
        translate([-axis_dist + sx * nema_hole_pitch / 2,
                   sy * nema_hole_pitch / 2, 0]) {
            // 대형 와셔 Ø9×1 (베이스 윗면)
            cylinder(d = 9, h = 1);
            // 볼트 머리 Ø5.5×3
            translate([0, 0, 1]) cylinder(d = 5.5, h = 3);
            // 축부 Ø3: 베이스 관통 → 모터 플랜지까지
            translate([0, 0, -base_t]) cylinder(d = 3, h = base_t + 1);
        }
}

// -----------------------------------------------------
// 5. 잭 스크류 M3×20 + 너트
// -----------------------------------------------------
module jack_screw() {
    // 모터 몸체 뒷면 x = -axis_dist - nema_side/2
    tip_x = -axis_dist - nema_side / 2;   // 스크류 +x쪽 끝
    z_c   = jack_block[2] / 2;            // 블록 M3 구멍 높이

    color(c_steel) {
        // 축부 Ø3×20 (x방향)
        translate([tip_x - 20, 0, z_c])
            rotate([0, 90, 0])
                cylinder(d = 3, h = 20);
        // 머리 Ø5.5 (−x쪽 끝)
        translate([tip_x - 20 - 3, 0, z_c])
            rotate([0, 90, 0])
                cylinder(d = 5.5, h = 3);
        // 잠금 너트 (블록 +x면 옆, 폭간 5.5 육각)
        translate([jack_block_x + jack_block[0] / 2, 0, z_c])
            rotate([0, 90, 0])
                cylinder(d = 5.5 / cos(30), h = 2.4, $fn = 6);
    }
}

// -----------------------------------------------------
// 6. GT2-280 폐루프 벨트
// -----------------------------------------------------
module belt() {
    color(c_belt)
    translate([0, 0, belt_z0])
        linear_extrude(height = belt_w)
            difference() {
                offset(delta = belt_t) _belt_path2d();
                _belt_path2d();
            }
}

// 풀리 외경(단순화 원통)에 감기는 벨트 안쪽 윤곽 2D (컨벡스 헐)
module _belt_path2d() {
    hull() {
        circle(r = p60_od / 2);
        translate([-axis_dist, 0]) circle(r = p20_od / 2);
    }
}
