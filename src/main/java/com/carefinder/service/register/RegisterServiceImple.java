package com.carefinder.service.register;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import com.carefinder.dao.member.MemberRegisterDAO;
import com.carefinder.dto.member.MemberRegisterDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class RegisterServiceImple implements RegisterService {

    private final MemberRegisterDAO memberRegisterDAO;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public String registerNormalMember(MemberRegisterDTO member) {

        // 1. 아이디 중복 체크
        if (memberRegisterDAO.checkIdDuplicate(member.getId()) > 0) {
            return "이미 사용 중인 아이디입니다.";
        }

        // 2. 전화번호 유효성 검사 (먼저 체크)
        if (member.getPhonenumber() != null && !member.getPhonenumber().isEmpty()) {
            String formattedPhone = formatPhoneNumber(member.getPhonenumber());

            // 형식이 틀리면 에러 메시지 리턴 (DB 저장 안 함)
            if (formattedPhone == null) {
                return "휴대폰 번호 형식이 올바르지 않습니다. (010-0000-0000 또는 숫자 11자리)";
            }
            member.setPhonenumber(formattedPhone);
        } else {
            // 필수값이라면 여기서 처리
            return "휴대폰 번호를 입력해주세요.";
        }

        // 3. 생년월일 → 나이 계산
        if (member.getBirth() != null && !member.getBirth().isEmpty()) {
            LocalDate birthDate = LocalDate.parse(member.getBirth());
            int age = Period.between(birthDate, LocalDate.now()).getYears();
            member.setAge(age);
        }

        // 4. 이메일 조합
        if (member.getEmailId() != null && member.getEmailDomain() != null) {
            member.setEmail(member.getEmailId() + member.getEmailDomain());
        }

        // 5. 비밀번호 암호화
        String encodedPw = passwordEncoder.encode(member.getPw());
        member.setPw(encodedPw);

        // DB 저장
        memberRegisterDAO.insertNormalMember(member);

        return "success"; // 성공 시 특정 문자열 반환
    }

    private String formatPhoneNumber(String phone) {
        String cleanedPhone = phone.replaceAll("[^0-9]", "");

        // 010으로 시작하고 11자리인지 엄격하게 체크
        if (cleanedPhone.length() == 11 && cleanedPhone.startsWith("010")) {
            return cleanedPhone.substring(0, 3) + "-" +
                    cleanedPhone.substring(3, 7) + "-" +
                    cleanedPhone.substring(7);
        }
        // 조건 안 맞으면 null 반환
        return null;
    }

    @Override
    public MemberRegisterDTO loginNormalMember(String id, String pw) {
        MemberRegisterDTO member = memberRegisterDAO.findNormalMemberById(id);
        if (member == null) return null;

        if (!passwordEncoder.matches(pw, member.getPw())) {
            return null;
        }
        return member;
    }

    @Override
    public boolean isIdDuplicate(String id) {
        return memberRegisterDAO.checkIdDuplicate(id) > 0;
    }
}