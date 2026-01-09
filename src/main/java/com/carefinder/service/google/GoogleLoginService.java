package com.carefinder.service.google;

import com.carefinder.dto.member.GoogleMemberDTO;
import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;

public interface GoogleLoginService {

    GoogleMemberDTO loginOrJoin(
            GoogleUserInfoDTO userInfo,
            GooglePeopleDTO people
    );
}
