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
    public boolean registerNormalMember(MemberRegisterDTO member) {

        // 아이디 중복 체크
        if (memberRegisterDAO.checkIdDuplicate(member.getId()) > 0) {
            return false;
        }

        //  생년월일 → 나이 계산
        if (member.getBirth() != null && !member.getBirth().isEmpty()) {
            LocalDate birthDate = LocalDate.parse(member.getBirth());
            int age = Period.between(birthDate, LocalDate.now()).getYears();
            member.setAge(age);
        }

        //  이메일 조합
        if (member.getEmailId() != null && member.getEmailDomain() != null) {
            member.setEmail(member.getEmailId() + member.getEmailDomain());
        }

        //  전화번호 포맷팅
        if (member.getPhonenumber() != null && !member.getPhonenumber().isEmpty()) {
            String formattedPhone = formatPhoneNumber(member.getPhonenumber());
            member.setPhonenumber(formattedPhone);
        }

        // 비밀번호 암호화
        String encodedPw = passwordEncoder.encode(member.getPw());
        member.setPw(encodedPw);


        memberRegisterDAO.insertNormalMember(member);
        return true;
    }

    //  전화번호 포맷 메서드
    private String formatPhoneNumber(String phone) {

        // 숫자만 남기기
        phone = phone.replaceAll("[^0-9]", "");

        // 010XXXXXXXX 형식만 허용
        if (phone.length() == 11 && phone.startsWith("010")) {
            return phone.substring(0, 3) + "-" +
                    phone.substring(3, 7) + "-" +
                    phone.substring(7);
        }

        // 그 외 형식은 원본 그대로 저장 (또는 null 처리 가능)
        return phone;
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
