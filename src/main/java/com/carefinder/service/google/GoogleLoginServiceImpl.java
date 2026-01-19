package com.carefinder.service.google;

import com.carefinder.dao.member.GoogleMemberDAO;
import com.carefinder.dto.member.GoogleMemberDTO;
import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GoogleLoginServiceImpl implements GoogleLoginService {

    private static final String SOCIAL_PASSWORD = "SOCIAL_LOGIN";

    private final GoogleMemberDAO googleMemberDAO;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public GoogleMemberDTO loginOrJoin(
            GoogleUserInfoDTO userInfo,
            GooglePeopleDTO people
    ) {

        if (userInfo.getSub() == null) {
            throw new IllegalStateException("Google sub is null");
        }

        // 구글 연동
        GoogleMemberDTO member =
                googleMemberDAO.findByGoogleId(userInfo.getSub());

        if (member != null) {
            if (people != null) {
                applyPeopleInfo(member, people);
                googleMemberDAO.updateExtraInfo(member);
            }
            return member;
        }

        // 기존 일반 회원
        member = googleMemberDAO.findByEmail(userInfo.getEmail());

        if (member != null) {
            member.setGoogleId(userInfo.getSub());

            if (people != null) {
                applyPeopleInfo(member, people);
                googleMemberDAO.updateExtraInfo(member);
            }

            googleMemberDAO.updateGoogleIdByEmail(
                    userInfo.getSub(),
                    userInfo.getEmail()
            );
            return member;
        }

        // 신규 회원
        GoogleMemberDTO newMember = new GoogleMemberDTO();

        newMember.setId("G_" + userInfo.getSub());
        newMember.setPw(
                passwordEncoder.encode(SOCIAL_PASSWORD)
        );

        newMember.setName(userInfo.getName());
        newMember.setEmail(userInfo.getEmail());
        newMember.setGoogleId(userInfo.getSub());

        applyPeopleInfo(newMember, people);

        googleMemberDAO.insertGoogleMember(newMember);
        return newMember;
    }

    private void applyPeopleInfo(
            GoogleMemberDTO member,
            GooglePeopleDTO people
    ) {
        if (people == null) return;

        if (people.getGender() != null)
            member.setGender(people.getGender());

        if (people.getAge() != null)
            member.setAge(people.getAge());

        if (people.getPhonenumber() != null)
            member.setPhonenumber(people.getPhonenumber());

        if (people.getBirth() != null)
            member.setBirth(people.getBirth());
    }
}

