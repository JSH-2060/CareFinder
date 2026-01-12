package com.carefinder.service.bmi;

import com.carefinder.dao.bmi.BmiCriteriaDAO;
import com.carefinder.dao.bmi.BmiDAO;
import com.carefinder.dao.bmi.ChildBmiPercentileDAO;
import com.carefinder.dao.child.ChildDAO;
import com.carefinder.dto.bmi.BmiCriteriaDTO;
import com.carefinder.dto.bmi.BmiDTO;
import com.carefinder.dto.bmi.ChildBmiPercentileDTO;
import com.carefinder.dto.child.ChildDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BmiService {

    private final BmiDAO bmiDAO;
    private final ChildDAO childDAO;
    private final BmiCriteriaDAO bmiCriteriaDAO;
    private final ChildBmiPercentileDAO childBmiPercentileDAO;

    /* ==================================================
       만나이(개월) 계산
    ================================================== */
    private int calculateAgeMonth(LocalDate birth, LocalDate 기준일) {
        Period p = Period.between(birth, 기준일);
        return p.getYears() * 12 + p.getMonths();
    }

    /* ==================================================
       🔥 bmi 테이블에 없는 birth/gender 보충
    ================================================== */
    private boolean fillChildInfoIfMissing(BmiDTO dto) {

        if (dto.getBirthDate() != null && dto.getGender() != null) {
            return true;
        }

        // 🔥 나(부모)는 통과
        if (dto.getChildId() == null) return true;

        ChildDTO child = childDAO.selectOne(dto.getChildId());
        if (child == null) return false;

        dto.setBirthDate(LocalDate.parse(child.getBirth()));
        dto.setGender(child.getGender());
        return true;
    }

    /* ==================================================
       BMI 계산 + 판정 + 기준바 퍼센트
    ================================================== */
    private boolean calculate(BmiDTO dto, LocalDate 기준일) {

        if (!fillChildInfoIfMissing(dto)) return false;
        if (dto.getHeight() == null || dto.getWeight() == null) return false;

        // 키 / 몸무게 범위
        if (dto.getHeight() < 80) return false;
        if (dto.getWeight() < 9 || dto.getWeight() >= 150) return false;

        int ageMonth = 0; // 🔥 여기서 먼저 선언

        // =========================
        // 나(부모)
        // =========================
        if (dto.getChildId() == null) {
            dto.setAdult(true);
        }
        // =========================
        // 자녀
        // =========================
        else {
            ageMonth = calculateAgeMonth(dto.getBirthDate(), 기준일);
            if (ageMonth < 24 || ageMonth > 1440) return false;

            dto.setAgeMonth(ageMonth);
            dto.setAdult(ageMonth >= 228);
        }

        // BMI 계산
        double h = dto.getHeight() / 100.0;
        double bmi = dto.getWeight() / (h * h);
        bmi = Math.round(bmi * 100) / 100.0;
        dto.setBmiValue(bmi);

        String result;
        double percent = 0;

    /* ==========================
       👶 소아 · 청소년
    ========================== */
        if (!dto.getAdult()) {

            ChildBmiPercentileDTO c =
                    childBmiPercentileDAO.findByGenderAndAgeMonth(
                            dto.getGender(), ageMonth   // ✅ 이제 정상
                    );
            if (c == null) return false;

            dto.setCut1(c.getP5());
            dto.setCut2(c.getP85());
            dto.setCut3(c.getP95());
            dto.setCut4(null);

            if (bmi < c.getP5()) {
                result = "저체중";
                percent = (bmi / c.getP5()) * 20;
            } else if (bmi < c.getP85()) {
                result = "정상";
                percent = 20 + ((bmi - c.getP5()) / (c.getP85() - c.getP5())) * 20;
            } else if (bmi < c.getP95()) {
                result = "과체중";
                percent = 40 + ((bmi - c.getP85()) / (c.getP95() - c.getP85())) * 20;
            } else {
                result = "비만";
                percent = 80;
            }
        }

    /* ==========================
       🧑 성인
    ========================== */
        else {

            int ageYear = ageMonth / 12; // 부모는 ageMonth=0 → 사용 안 됨

            BmiCriteriaDTO c =
                    bmiCriteriaDAO.findByGenderAndAge(dto.getGender(), ageYear);

// 🔥 부모 + 기준 없음 → 기본 성인 처리
            if (c == null) {
                dto.setResult("정상");
                dto.setBmiPercent(Double.valueOf(50));
                return true;   // ❗ 여기서 통과시켜 insert 되게 함
            }

            dto.setCut1(c.getUnderBmi());
            dto.setCut2(c.getNormalBmi());
            dto.setCut3(c.getObeseBmi());
            dto.setCut4(c.getSevereBmi());

            if (bmi < c.getUnderBmi()) {
                result = "저체중";
                percent = (bmi / c.getUnderBmi()) * 20;
            } else if (bmi < c.getNormalBmi()) {
                result = "정상";
                percent = 20 + ((bmi - c.getUnderBmi()) / (c.getNormalBmi() - c.getUnderBmi())) * 20;
            } else if (bmi < c.getObeseBmi()) {
                result = "과체중";
                percent = 40 + ((bmi - c.getNormalBmi()) / (c.getObeseBmi() - c.getNormalBmi())) * 20;
            } else if (bmi < c.getSevereBmi()) {
                result = "비만";
                percent = 60 + ((bmi - c.getObeseBmi()) / (c.getSevereBmi() - c.getObeseBmi())) * 20;
            } else {
                result = "고도비만";
                percent = 100;
            }
        }

        dto.setResult(result);
        dto.setBmiPercent(Math.min(100, Math.max(0, percent)));
        return true;
    }

    /* ==================================================
       BMI 계산 + 저장
    ================================================== */
    public BmiDTO calculateAndSave(BmiDTO dto, Long mno) {
        dto.setMno(mno);

        System.out.println(">>> [BMI] before calculate: childId=" + dto.getChildId());

        boolean ok = calculate(dto, LocalDate.now());
        System.out.println(">>> [BMI] calculate result = " + ok);

        if (!ok) return dto;

        System.out.println(">>> [BMI] before insert");
        bmiDAO.insert(dto);
        System.out.println(">>> [BMI] after insert");

        return dto;
    }

    /* ==================================================
       자녀 기준 BMI 리스트
    ================================================== */
    public List<BmiDTO> getBmiListByChild(Long mno, Integer childId) {
        List<BmiDTO> list = bmiDAO.findByChild(mno, childId);
        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            calculate(dto, dto.getRecordDate().toLocalDate());
        }
        return list;
    }

    /* ==================================================
       날짜 조건
    ================================================== */
    public List<BmiDTO> getBmiListByDate(
            Long mno, Integer childId, String startDate, String endDate) {

        List<BmiDTO> list =
                bmiDAO.findByDateRangeAndChild(mno, childId, startDate, endDate);

        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            calculate(dto, dto.getRecordDate().toLocalDate());
        }
        return list;
    }

    /* ==================================================
       단건 조회
    ================================================== */
    public BmiDTO getBmiById(Long bmiNo) {
        BmiDTO dto = bmiDAO.findById(bmiNo);
        if (dto == null) return null;
        calculate(dto, dto.getRecordDate().toLocalDate());
        return dto;
    }

    /* ==================================================
       최근 BMI (기준바용)
    ================================================== */
    public BmiDTO getLatestBmi(Integer childId) {
        BmiDTO dto = bmiDAO.findLatestByChildId(childId);
        if (dto == null) return null;
        calculate(dto, dto.getRecordDate().toLocalDate());
        return dto;
    }

    /* ==================================================
       수정
    ================================================== */
    public void updateBmi(BmiDTO dto) {

        BmiDTO origin = bmiDAO.findById(dto.getBmiNo());
        if (origin == null) return;

        dto.setChildId(origin.getChildId());
        dto.setMno(origin.getMno());
        dto.setBirthDate(origin.getBirthDate());
        dto.setGender(origin.getGender());
        dto.setRecordDate(origin.getRecordDate());

        if (!calculate(dto, origin.getRecordDate().toLocalDate())) return;
        bmiDAO.update(dto);
    }

    /* ==================================================
       삭제
    ================================================== */
    public void deleteBmi(Long bmiNo) {
        bmiDAO.deleteByBmiNo(bmiNo);
    }

    public List<ChildDTO> getChildList(Long mno) {
        return bmiDAO.selectChildList(mno);
    }
}
