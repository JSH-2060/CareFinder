package com.carefinder.service.child;

import com.carefinder.dao.child.ChildDAO;
import com.carefinder.dto.child.ChildDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChildService {

    private final ChildDAO childDAO;

    public void insertChild(ChildDTO dto) {
        childDAO.insert(dto);
    }

    public List<ChildDTO> getChildList(Long mno) {
        return childDAO.getChildList(mno);
    }

    // 1. ID로 아이 정보 한 명 가져오기
    public ChildDTO getChildById(Integer childId) {
        return childDAO.selectOne(childId);
    }

    // 2. 수정
    public void updateChild(ChildDTO dto) {
        childDAO.update(dto);
    }

    // 3. 삭제
    public void deleteChild(Integer childId) {
        childDAO.delete(childId);
    }
}