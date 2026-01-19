package com.carefinder.controller.map;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class DrugController {
    @Value("${drug.service-key}")
    private String SERVICE_KEY;

    @GetMapping({"/drug"})
    public String drugPage() {
        return "drug/drugs";
    }

    @GetMapping({"/drug/search"})
    @ResponseBody
    public List<Map<String, Object>> searchDrug(@RequestParam("name") String name) {
        List<Map<String, Object>> result = new ArrayList<>();

        try {
            String urlStr = "http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"
                    + "?serviceKey=" + SERVICE_KEY
                    + "&itemName=" + URLEncoder.encode(name, "UTF-8")
                    + "&numOfRows=10&pageNo=1";

            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            InputStream is = conn.getInputStream();
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(is);
            NodeList items = doc.getElementsByTagName("item");

            for (int i = 0; i < items.getLength(); i++) {
                Element item = (Element) items.item(i);
                Map<String, Object> drug = new HashMap<>();
                drug.put("itemName", getValue(item, "itemName"));
                drug.put("entpName", getValue(item, "entpName"));
                drug.put("efcyQesitm", getValue(item, "efcyQesitm"));
                drug.put("useMethodQesitm", getValue(item, "useMethodQesitm"));
                drug.put("atpnWarnQesitm", getValue(item, "atpnWarnQesitm"));
                drug.put("atpnQesitm", getValue(item, "atpnQesitm"));
                drug.put("intrcQesitm", getValue(item, "intrcQesitm"));
                drug.put("seQesitm", getValue(item, "seQesitm"));
                drug.put("depositMethodQesitm", getValue(item, "depositMethodQesitm"));
                drug.put("itemImage", getValue(item, "itemImage"));
                result.add(drug);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    @GetMapping({"/drug/searchByShape"})
    @ResponseBody
    public List<Map<String, Object>> searchByShape(
            @RequestParam(value = "shape", required = false) String shape,
            @RequestParam(value = "color", required = false) String color,
            @RequestParam(value = "print", required = false) String print) {

        List<Map<String, Object>> result = new ArrayList<>();
        final int MAX_RESULTS = 30;

        try {
            outerLoop:
            for (int pageNo = 1; pageNo <= 50; pageNo++) {
                String urlStr = "https://apis.data.go.kr/1471000/MdcinGrnIdntfcInfoService03/getMdcinGrnIdntfcInfoList03"
                        + "?serviceKey=" + SERVICE_KEY
                        + "&numOfRows=500&pageNo=" + pageNo + "&type=json";

                URL url = new URL(urlStr);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setRequestProperty("Accept", "application/json");

                int responseCode = conn.getResponseCode();
                if (responseCode != 200) {
                    System.out.println("API 응답 코드: " + responseCode);
                    continue;
                }

                BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)
                );
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();

                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(response.toString());
                JsonNode body = root.path("body");
                JsonNode items = body.path("items");

                if (items != null && items.isArray()) {
                    for (JsonNode item : items) {
                        if (!matchesFilter(item, shape, color, print)) {
                            continue;
                        }

                        Map<String, Object> drug = new HashMap<>();
                        drug.put("itemName", getJsonValue(item, "ITEM_NAME"));
                        drug.put("entpName", getJsonValue(item, "ENTP_NAME"));
                        drug.put("itemImage", getJsonValue(item, "ITEM_IMAGE"));
                        drug.put("drugShape", getJsonValue(item, "DRUG_SHAPE"));
                        drug.put("colorClass1", getJsonValue(item, "COLOR_CLASS1"));
                        drug.put("colorClass2", getJsonValue(item, "COLOR_CLASS2"));
                        drug.put("printFront", getJsonValue(item, "PRINT_FRONT"));
                        drug.put("printBack", getJsonValue(item, "PRINT_BACK"));
                        drug.put("lineFront", getJsonValue(item, "LINE_FRONT"));
                        drug.put("lineBack", getJsonValue(item, "LINE_BACK"));
                        drug.put("lengLong", getJsonValue(item, "LENG_LONG"));
                        drug.put("lengShort", getJsonValue(item, "LENG_SHORT"));
                        drug.put("thick", getJsonValue(item, "THICK"));
                        drug.put("className", getJsonValue(item, "CLASS_NAME"));
                        drug.put("etcOtcName", getJsonValue(item, "ETC_OTC_NAME"));
                        drug.put("formCodeName", getJsonValue(item, "FORM_CODE_NAME"));
                        result.add(drug);

                        if (result.size() >= MAX_RESULTS) {
                            break outerLoop;
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    private boolean matchesFilter(JsonNode item, String shape, String color, String print) {
        if (shape != null && !shape.isEmpty()) {
            String drugShape = getJsonValue(item, "DRUG_SHAPE");
            if (drugShape == null || !drugShape.equals(shape)) {
                return false;
            }
        }

        if (color != null && !color.isEmpty()) {
            String color1 = getJsonValue(item, "COLOR_CLASS1");
            String color2 = getJsonValue(item, "COLOR_CLASS2");
            boolean colorMatch = (color1 != null && color1.contains(color))
                    || (color2 != null && color2.contains(color));
            if (!colorMatch) {
                return false;
            }
        }

        if (print != null && !print.isEmpty()) {
            String printUpper = print.toUpperCase();
            String front = getJsonValue(item, "PRINT_FRONT");
            String back = getJsonValue(item, "PRINT_BACK");
            boolean printMatch = (front != null && front.toUpperCase().contains(printUpper))
                    || (back != null && back.toUpperCase().contains(printUpper));
            if (!printMatch) {
                return false;
            }
        }

        return true;
    }

    private String getValue(Element element, String tagName) {
        try {
            NodeList nodeList = element.getElementsByTagName(tagName);
            if (nodeList.getLength() > 0) {
                String text = nodeList.item(0).getTextContent();
                if (text != null && !text.trim().isEmpty()) {
                    return text.trim();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getJsonValue(JsonNode node, String fieldName) {
        JsonNode field = node.get(fieldName);
        if (field != null && !field.isNull()) {
            return field.asText();
        }
        return null;
    }
}
